////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Выполняет распределение общей суммы дивидендов между акционерами пропорционально количеству акций
Процедура РассчитатьДивиденды() Экспорт
	
	ВсегоАкций = Начисления.Итог("КоличествоАкций");
	
	Если НаОднуАкцию Тогда
		// Сумму к начислению указанна в расчете на одну акцию
		СуммаНаАкцию =  ДивидендыНачисляемые;
		Для каждого  Строка Из Начисления Цикл
			Строка.Результат = Строка.КоличествоАкций * СуммаНаАкцию;
		КонецЦикла; 
	Иначе
		// Начисляемые дивиденды надо распределить пропорционально количеству акций			
		МассивСуммКНачислению = ОбщегоНазначения.РаспределитьПропорционально(ДивидендыНачисляемые,Начисления.ВыгрузитьКолонку("КоличествоАкций"));
		Если МассивСуммКНачислению <> Неопределено Тогда
			Начисления.ЗагрузитьКолонку(МассивСуммКНачислению,"Результат")
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры

// Выполняет распределение общей суммы полученных дивидентов(вычета) между акционерами пропорционально количеству акций
// Вычеты распределяются только между налоговыми резидентами
Процедура РассчитатьНДФЛ() Экспорт
	
	Запрос = Новый Запрос;
	
	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка", Ссылка);
	Запрос.УстановитьПараметр("ДатаНачисления", КонецМесяца(ПериодРегистрации));

	Запрос.УстановитьПараметр("СтавкаРезидента", ПроведениеРасчетов.ПолучитьСтавкуНДФЛ(КонецМесяца(ПериодРегистрации), Перечисления.ВидыСтавокНДФЛ.Основная));
	Запрос.УстановитьПараметр("СтавкаНеРезидента", ПроведениеРасчетов.ПолучитьСтавкуНДФЛ(КонецМесяца(ПериодРегистрации), Перечисления.ВидыСтавокНДФЛ.Основная));
	
    // Описание текста запроса:
    // 1. Выборка "НачислениеДивидендовОрганизацииНачисления": 
	//		Выбираются строки документа.  
	// 2. Выборка "ГражданствоФизЛицСрезПоследних": 
	//		Из регистра сведений о гражданстве выбираем информацию о налоговом резидентстве работника - 
	//		для расчета вычетов по НДФЛ и сумм НДФЛ
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НачислениеДивидендовОрганизацииНачисления.Сотрудник,
	|	НачислениеДивидендовОрганизацииНачисления.КоличествоАкций,
	|	НачислениеДивидендовОрганизацииНачисления.Результат,
	|	НачислениеДивидендовОрганизацииНачисления.НДФЛ,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ГражданствоФизЛицСрезПоследних.НеЯвляетсяНалоговымРезидентом, ЛОЖЬ)
	|			ТОГДА &СтавкаНеРезидента
	|		ИНАЧЕ &СтавкаРезидента
	|	КОНЕЦ КАК СтавкаНДФЛ
	|ИЗ Документ.НачислениеДивидендовОрганизаций.Начисления КАК НачислениеДивидендовОрганизацииНачисления
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ГражданствоФизЛиц.СрезПоследних(&ДатаНачисления) КАК ГражданствоФизЛицСрезПоследних
	|ПО		НачислениеДивидендовОрганизацииНачисления.Сотрудник.Физлицо = ГражданствоФизЛицСрезПоследних.ФизЛицо
	|
	|ГДЕ НачислениеДивидендовОрганизацииНачисления.Ссылка = &ДокументСсылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НачислениеДивидендовОрганизацииНачисления.НомерСтроки
	|";
	
	ВременнаяТаблица = Запрос.Выполнить().Выгрузить();
	
	Для каждого СтрокаТЧ Из ВременнаяТаблица Цикл
		СтрокаТЧ.НДФЛ = Макс(СтрокаТЧ.Результат,0) * СтрокаТЧ.СтавкаНДФЛ;
	КонецЦикла;
	
	Начисления.Загрузить(ВременнаяТаблица);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

Функция СформироватьЗапросПоШапке()

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);
	Запрос.УстановитьПараметр("парамПустаяОрганизация", Справочники.Организации.ПустаяСсылка());

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НачислениеДивидендовОрганизаций.Дата,
	|	НачислениеДивидендовОрганизаций.Организация,
	|	НачислениеДивидендовОрганизаций.ПериодРегистрации,
	|	ВЫБОР
	|		КОГДА НачислениеДивидендовОрганизаций.Организация.ГоловнаяОрганизация = &парамПустаяОрганизация
	|			ТОГДА НачислениеДивидендовОрганизаций.Организация
	|		ИНАЧЕ НачислениеДивидендовОрганизаций.Организация.ГоловнаяОрганизация
	|	КОНЕЦ КАК ГоловнаяОрганизация,
	|	НачислениеДивидендовОрганизаций.Организация КАК ОбособленноеПодразделение,
	|	НачислениеДивидендовОрганизаций.Ответственный,
	|	НачислениеДивидендовОрганизаций.Ссылка
	|ИЗ
	|	Документ.НачислениеДивидендовОрганизаций КАК НачислениеДивидендовОрганизаций
	|ГДЕ
	|	НачислениеДивидендовОрганизаций.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

Функция СформироватьЗапросПоНачисления()

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка", Ссылка);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ПериодРегистрации", ПериодРегистрации);
	Запрос.УстановитьПараметр("ДатаНачисления", КонецМесяца(ПериодРегистрации));
	Запрос.УстановитьПараметр("парамСотрудники", Начисления.ВыгрузитьКолонку("Сотрудник"));

	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	Основной.НомерСтроки			КАК НомерСтроки,
	|	Основной.Сотрудник			КАК Сотрудник,
	|	Основной.Сотрудник			КАК Назначение,
	|	Основной.Ссылка.Организация	КАК Организация,
	|	&ПериодРегистрации КАК ПериодВзаиморасчетов,
	|	&ПериодРегистрации КАК НалоговыйПериод,
	|	&ПериодРегистрации КАК Период,
	|	&ПериодРегистрации КАК ПериодРегистрации,
	|	&ПериодРегистрации						КАК ПериодДействияНачало,
	|	КОНЕЦПЕРИОДА(&ПериодРегистрации, МЕСЯЦ) КАК ПериодДействияКонец,
	|	&ПериодРегистрации						КАК БазовыйПериодНачало,
	|	КОНЕЦПЕРИОДА(&ПериодРегистрации, МЕСЯЦ) КАК БазовыйПериодКонец,
	|
	|	Основной.Результат КАК Результат,
	|	Основной.Результат КАК СуммаВзаиморасчетов,
	|	ЗНАЧЕНИЕ(Перечисление.КодыОперацийВзаиморасчетыСРаботникамиОрганизаций.Начисления) КАК КодОперации,
	|	ЗНАЧЕНИЕ(ПланВидовРасчета.ОсновныеНачисленияОрганизаций.ДивидендыРаботников) КАК ВидРасчета,
	|	ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыПоНачисленнымДивидендам ) КАК СчетУчета,
	|
	|	ЗНАЧЕНИЕ(Справочник.ВидыДоходовНДФЛ.Код12) КАК ДоходНДФЛ,
	|	Основной.Результат КАК Доход,
	|	Основной.НДФЛ КАК Налог,
	|	Работники.ПодразделениеОрганизации,
	|ЗНАЧЕНИЕ(Перечисление.ВидыСтавокНДФЛ.Основная) КАК ВидСтавки
	
	|ИЗ Документ.НачислениеДивидендовОрганизаций.Начисления КАК Основной
	|
	|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			Работники.Сотрудник,
	|			Работники.ПодразделениеОрганизации
	|		ИЗ
	|			РегистрСведений.РаботникиОрганизаций.СрезПоследних(&ДатаНачисления,
	|				 Организация = &Организация
	|					И Сотрудник.ВидЗанятости <> ЗНАЧЕНИЕ(Перечисление.ВидыЗанятостиВОрганизации.ВнутреннееСовместительство)
	|					И Сотрудник В (&парамСотрудники)) КАК Работники
	|			) КАК Работники
	|		ПО Работники.Сотрудник = Основной.Сотрудник
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ГражданствоФизЛиц.СрезПоследних(&ДатаНачисления) КАК ГражданствоФизЛицСрезПоследних
	|ПО		Основной.Сотрудник.Физлицо = ГражданствоФизЛицСрезПоследних.ФизЛицо
	|
	|ГДЕ	Основной.Ссылка = &ДокументСсылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";

	Запрос.Текст = ТекстЗапроса;

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоНачисления()


Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок)

	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Организация) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана организация!", Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

Процедура ПроверитьЗаполнениеСтрокиРаботникаОрганизации(ВыборкаПоШапкеДокумента, ВыборкаПоСтрокамДокумента, Отказ, Заголовок)
	
	СтрокаНачалаСообщенияОбОшибке = "В строке номер """+ СокрЛП(ВыборкаПоСтрокамДокумента.НомерСтроки) +
	""" табл. части ""Начисления"": ";

	// Сотрудник
	Если НЕ ЗначениеЗаполнено(ВыборкаПоСтрокамДокумента.Сотрудник) Тогда
		ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + "не указан акционер!", Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры


Процедура ДобавитьСтрокуОсновныхНачислений(ВыборкаПоСтрокамДокумента, НаборЗаписей)
	
	Движение = НаборЗаписей.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, ВыборкаПоСтрокамДокумента);

КонецПроцедуры // ДобавитьСтрокуОсновныхНачислений()

Процедура ДобавитьСтрокуВзаиморасчетыСРаботникамиОрганизаций(ВыборкаПоСтрокамДокумента)
	
	// ВзаиморасчетыСРаботникамиОрганизаций
	Движение = Движения.ВзаиморасчетыСРаботникамиОрганизаций.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, ВыборкаПоСтрокамДокумента);
	Движение.ВидДвижения			= ВидДвиженияНакопления.Приход;

	Движение = Движения.ВзаиморасчетыСРаботникамиОрганизаций.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, ВыборкаПоСтрокамДокумента);
	Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
	Движение.СуммаВзаиморасчетов	= ВыборкаПоСтрокамДокумента.Налог;
	Движение.КодОперации			= Перечисления.КодыОперацийВзаиморасчетыСРаботникамиОрганизаций.НДФЛ;
	
КонецПроцедуры // ДобавитьСтрокуВДвиженияПоРегистрамНакопления()

Процедура ДобавитьСтрокуВзаиморасчетыПоНДФЛ(ВыборкаПоСтрокамДокумента)
	
	// ВзаиморасчетыСРаботникамиОрганизаций
	Движение = Движения.ВзаиморасчетыПоНДФЛ.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, ВыборкаПоСтрокамДокумента);
	Движение.ВидДвижения			= ВидДвиженияНакопления.Приход;
	
КонецПроцедуры // ДобавитьСтрокуВДвиженияПоРегистрамНакопления()



////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	РезультатЗапросаПоШапке = СформироватьЗапросПоШапке();
	ВыборкаПоШапкеДокумента = РезультатЗапросаПоШапке.Выбрать();

	Если ВыборкаПоШапкеДокумента.Следующий() Тогда

		ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок);

		Если НЕ Отказ Тогда
			
			ВыборкаПоНачислениям = СформироватьЗапросПоНачисления().Выбрать();
			Пока ВыборкаПоНачислениям.СледующийПоЗначениюПоля("НомерСтроки") Цикл 

				ПроверитьЗаполнениеСтрокиРаботникаОрганизации(ВыборкаПоШапкеДокумента, ВыборкаПоНачислениям, Отказ, Заголовок);
				Если НЕ Отказ Тогда
					
					// В регистр расчета начисления пишем только для работников организации
					ДобавитьСтрокуОсновныхНачислений(ВыборкаПоНачислениям, Движения.ОсновныеНачисленияРаботниковОрганизаций);
					ДобавитьСтрокуВзаиморасчетыСРаботникамиОрганизаций(ВыборкаПоНачислениям);
					ДобавитьСтрокуВзаиморасчетыПоНДФЛ(ВыборкаПоНачислениям);
					
				КонецЕсли;
				
			КонецЦикла;
		КонецЕсли; 
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	КраткийСоставДокумента = ПроцедурыУправленияПерсоналом.ЗаполнитьКраткийСоставДокумента(Начисления,, "Сотрудник");
	ПроцедурыУправленияПерсоналом.ЗаполнитьФизЛицоПоТЧ(Начисления);
	
КонецПроцедуры
