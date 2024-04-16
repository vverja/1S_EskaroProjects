#Если Клиент Тогда
// Выполняет настройку отчета по умолчанию.
// 
Процедура УстановитьНачальныеНастройки(ДополнительныеПараметры = Неопределено) Экспорт
	
	// Настройка общих параметров универсального отчета
	
	// Содержит название отчета, которое будет выводиться в шапке.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.мНазваниеОтчета = "Название отчета";
	УниверсальныйОтчет.мНазваниеОтчета = СокрЛП(ЭтотОбъект.Метаданные().Синоним);
	
	// Содержит признак необходимости отображения надписи и поля выбора раздела учета в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИмяРегистра = Истина;
	УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	
	// Содержит имя регистра, по метаданным которого будет выполняться заполнение настроек отчета.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.ИмяРегистра = "НДСПриобретений";
	УниверсальныйОтчет.ИмяРегистра = "";
	
	// Содержит признак необходимости вывода отрицательных значений показателей красным цветом.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	
	// Содержит признак необходимости вывода в отчет общих итогов.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ВыводитьОбщиеИтоги = Ложь;
	УниверсальныйОтчет.ВыводитьОбщиеИтоги = Ложь;
	
	// Содержит признак необходимости вывода детальных записей в отчет.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ВыводитьДетальныеЗаписи = Истина;
	
	// Содержит признак необходимости отображения флага использования свойств и категорий в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Ложь;
	УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Истина;
	
	// Содержит признак использования свойств и категорий при заполнении настроек отчета.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.ИспользоватьСвойстваИКатегории = Истина;
	//УниверсальныйОтчет.ИспользоватьСвойстваИКатегории = Истина;
	
	// Содержит признак использования простой формы настроек отчета без группировок колонок.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.мРежимФормыНастройкиБезГруппировокКолонок = Истина;
	
	// Дополнительные параметры, переданные из отчета, вызвавшего расшифровку.
	// Информация, передаваемая в переменной ДополнительныеПараметры, может быть использована
	// для реализации специфичных для данного отчета параметрических настроек.
	
	// Описание исходного текста запроса.
	// При написании текста запроса рекомендуется следовать правилам, описанным в следующем шаблоне текста запроса:
	//
	//ВЫБРАТЬ
	//	<ПсевдонимТаблицы.Поле> КАК <ПсевдонимПоля>,
	//	ПРЕДСТАВЛЕНИЕ(<ПсевдонимТаблицы>.<Поле>),
	//	<ПсевдонимТаблицы.Показатель> КАК <ПсевдонимПоказателя>
	//	//ПОЛЯ_СВОЙСТВА
	//	//ПОЛЯ_КАТЕГОРИИ
	//{ВЫБРАТЬ
	//	<ПсевдонимПоля>.*,
	//	<ПсевдонимПоказателя>,
	//	Регистратор,
	//	Период,
	//	ПериодДень,
	//	ПериодНеделя,
	//	ПериодДекада,
	//	ПериодМесяц,
	//	ПериодКвартал,
	//	ПериодПолугодие,
	//	ПериодГод
	//	//ПОЛЯ_СВОЙСТВА
	//	//ПОЛЯ_КАТЕГОРИИ
	//}
	//ИЗ
	//	<Таблица> КАК <ПсевдонимТаблицы>
	//	//СОЕДИНЕНИЯ
	//{ГДЕ
	//	<ПсевдонимТаблицы.Поле>.* КАК <ПсевдонимПоля>,
	//	<ПсевдонимТаблицы.Показатель> КАК <ПсевдонимПоказателя>,
	//	<ПсевдонимТаблицы>.Регистратор КАК Регистратор,
	//	<ПсевдонимТаблицы>.Период КАК Период,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, ДЕНЬ) КАК ПериодДень,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, НЕДЕЛЯ) КАК ПериодНеделя,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, ДЕКАДА) КАК ПериодДекада,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, МЕСЯЦ) КАК ПериодМесяц,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, КВАРТАЛ) КАК ПериодКвартал,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, ПОЛУГОДИЕ) КАК ПериодПолугодие,
	//	НАЧАЛОПЕРИОДА(<ПсевдонимТаблицы>.Период, ГОД) КАК ПериодГод
	//	//ПОЛЯ_СВОЙСТВА
	//	//ПОЛЯ_КАТЕГОРИИ
	//}
	//{УПОРЯДОЧИТЬ ПО
	//	<ПсевдонимПоля>.*,
	//	<ПсевдонимПоказателя>,
	//	Регистратор,
	//	Период,
	//	ПериодДень,
	//	ПериодНеделя,
	//	ПериодДекада,
	//	ПериодМесяц,
	//	ПериодКвартал,
	//	ПериодПолугодие,
	//	ПериодГод
	//	//УПОРЯДОЧИТЬ_СВОЙСТВА
	//	//УПОРЯДОЧИТЬ_КАТЕГОРИИ
	//}
	//ИТОГИ
	//	АГРЕГАТНАЯ_ФУНКЦИЯ(<ПсевдонимПоказателя>)
	//	//ИТОГИ_СВОЙСТВА
	//	//ИТОГИ_КАТЕГОРИИ
	//ПО
	//	ОБЩИЕ
	//{ИТОГИ ПО
	//	<ПсевдонимПоля>.*,
	//	Регистратор,
	//	Период,
	//	ПериодДень,
	//	ПериодНеделя,
	//	ПериодДекада,
	//	ПериодМесяц,
	//	ПериодКвартал,
	//	ПериодПолугодие,
	//	ПериодГод
	//	//ПОЛЯ_СВОЙСТВА
	//	//ПОЛЯ_КАТЕГОРИИ
	//}
	//АВТОУПОРЯДОЧИВАНИЕ

	Текст = 
		  "ВЫБРАТЬ Разрешенные
		  |	НДС.Организация КАК Организация,
		  |	НДС.ДоговорКонтрагента.Владелец КАК Контрагент,
		  |	НДС.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК Валюта,
		  |	НДС.Сделка КАК Сделка,
		  |	НДС.ДоговорКонтрагента КАК ДоговорКонтрагента,
		  |	ВЫБОР КОГДА НДС.ВозвратнаяТара = ИСТИНА ТОГДА ""Возвратная тара"" ИНАЧЕ ""Товары"" КОНЕЦ КАК ВозвратнаяТара,
		  |	НДС.СобытиеНДС,
		  |	НДС.СтавкаНДС,
		  |	НДС.НалоговоеНазначение,
		  |	НДС.Регистратор,
		  |	ВЫБОР
		  |		КОГДА НДС.ВидДвижения = &Приход
		  |			ТОГДА НДС.БазаНДС
		  |		ИНАЧЕ 0
		  |	КОНЕЦ КАК ОжидаемыйБазаНДС,
		  |	ВЫБОР
		  |		КОГДА НДС.ВидДвижения = &Приход
		  |			ТОГДА НДС.СуммаНДС
		  |		ИНАЧЕ 0
		  |	КОНЕЦ КАК ОжидаемыйСуммаНДС,
		  |	ВЫБОР
		  |		КОГДА (НЕ НДС.ВидДвижения = &Приход)
		  |			ТОГДА НДС.БазаНДС
		  |		ИНАЧЕ 0
		  |	КОНЕЦ КАК ПодтвержденныйБазаНДС,
		  |	ВЫБОР
		  |		КОГДА (НЕ НДС.ВидДвижения = &Приход)
		  |			ТОГДА НДС.СуммаНДС
		  |		ИНАЧЕ 0
		  |	КОНЕЦ КАК ПодтвержденныйСуммаНДС,
		  |	ВЫБОР
		  |		КОГДА НДС.ВидДвижения = &Приход
		  |			ТОГДА НДС.БазаНДС
		  |		ИНАЧЕ -НДС.БазаНДС
		  |	КОНЕЦ КАК НеПодтвержденныйБазаНДС,
		  |	ВЫБОР
		  |		КОГДА НДС.ВидДвижения = &Приход
		  |			ТОГДА НДС.СуммаНДС
		  |		ИНАЧЕ -НДС.СуммаНДС
		  |	КОНЕЦ КАК НеПодтвержденныйСуммаНДС
		  |{ВЫБРАТЬ
		  |	Организация.*,
		  |	НДС.ДоговорКонтрагента.Владелец.* КАК Контрагент,
		  |	ДоговорКонтрагента.*,
		  |	Сделка.*,
		  |	НДС.НалоговоеНазначение.*,
		  |	ОжидаемыйБазаНДС,
		  |	ОжидаемыйСуммаНДС,
		  |	ПодтвержденныйБазаНДС,
		  |	ПодтвержденныйСуммаНДС,
		  |	НеПодтвержденныйБазаНДС,
		  |	НеПодтвержденныйСуммаНДС,
		  | Регистратор
		  |}
		  |ИЗ
		  |	РегистрНакопления.ОжидаемыйИПодтвержденныйНДСПродаж КАК НДС
		  |
		  |ГДЕ НДС.Период >= &ДатаНачала 
		  |  И НДС.Период <= &ДатаКонца
		  |
		  |{ГДЕ
		  |	Организация.*,
		  |	НДС.ДоговорКонтрагента.Владелец.* КАК Контрагент,
		  |	ДоговорКонтрагента.*,
		  |	Сделка.*,
		  |	НДС.ДоговорКонтрагента.ВалютаВзаиморасчетов.*,
		  |	НДС.ВозвратнаяТара КАК ВозвратнаяТара,
		  | НДС.СобытиеНДС,
		  |	НДС.СтавкаНДС,
		  |	НДС.НалоговоеНазначение.*}
  		  |УПОРЯДОЧИТЬ ПО
		  | СобытиеНДС
		  |{УПОРЯДОЧИТЬ ПО
		  |	СобытиеНДС,
		  |	Организация.*,
		  |	Контрагент.*,
		  |	ДоговорКонтрагента.*}
		  |ИТОГИ
		  |	СУММА(ОжидаемыйСуммаНДС),
		  |	СУММА(ОжидаемыйБазаНДС),
		  |	СУММА(ПодтвержденныйСуммаНДС),
		  |	СУММА(ПодтвержденныйБазаНДС),
		  |	СУММА(НеПодтвержденныйСуммаНДС),
		  |	СУММА(НеПодтвержденныйБазаНДС)
		  |ПО
		  |	Организация,
		  |	Валюта,
		  |	Контрагент,
		  | ДоговорКонтрагента,
		  | Сделка,
		  | ВозвратнаяТара,
		  | СтавкаНДС,
		  | НалоговоеНазначение
		  |
		  |{ИТОГИ ПО
		  |	Организация.*,
		  |	Валюта,
		  |	НДС.ДоговорКонтрагента.Владелец.* КАК Контрагент,
		  |	ДоговорКонтрагента.*,
		  |	Сделка.*,
		  |	ВЫБОР КОГДА НДС.ВозвратнаяТара = ИСТИНА ТОГДА ""Возвратная тара"" ИНАЧЕ ""Товары"" КОНЕЦ КАК ВозвратнаяТара,
		  |	НДС.СобытиеНДС,
		  |	НДС.СтавкаНДС,
		  |	НДС.НалоговоеНазначение.*,
		  | НДС.Регистратор
		  |}";
 

	УниверсальныйОтчет.ПостроительОтчета.Текст = Текст;
	
	УниверсальныйОтчет.ПостроительОтчета.Параметры.Вставить("Приход", 						ВидДвиженияНакопления.Приход);
	
	// Представления полей отчета.
	// Необходимо вызывать для каждого поля запроса.
	// УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить(<ИмяПоля>, <ПредставлениеПоля>);
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Организация",				"Организация");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Контрагент", 				"Контрагент");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Сделка", 					"Сделка");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ДоговорКонтрагента",		"Договор");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("ВозвратнаяТара", 			"Расчеты по таре");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("СобытиеНДС",				"Вид расчетов");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("Валюта",					"Валюта взаиморасчетов");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("СтавкаНДС", 				"Ставка НДС");
	УниверсальныйОтчет.мСтруктураПредставлениеПолей.Вставить("НалоговоеНажначение", 	"Налоговое назначение");
	
	УниверсальныйОтчет.ДобавитьПоказатель("ОжидаемыйБазаНДС",  "Ожидаемый НДС (база)", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	УниверсальныйОтчет.ДобавитьПоказатель("ОжидаемыйСуммаНДС","Ожидаемый НДС", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	УниверсальныйОтчет.ДобавитьПоказатель("ПодтвержденныйБазаНДС","Подтвержд. НДС (база)", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	УниверсальныйОтчет.ДобавитьПоказатель("ПодтвержденныйСуммаНДС","Подтвержд. НДС", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	УниверсальныйОтчет.ДобавитьПоказатель("НеПодтвержденныйБазаНДС","Не подтвержд. НДС (база)", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	УниверсальныйОтчет.ДобавитьПоказатель("НеПодтвержденныйСуммаНДС","Не подтвержд. НДС", ИСТИНА,   "ЧЦ = 15; ЧДЦ = 3");
	
	// Добавление показателей
	// Необходимо вызывать для каждого добавляемого показателя.
	// УниверсальныйОтчет.ДобавитьПоказатель(<ИмяПоказателя>, <ПредставлениеПоказателя>, <ВключенПоУмолчанию>, <Формат>, <ИмяГруппы>, <ПредставлениеГруппы>);

	// Добавление предопределенных группировок строк отчета.
	// Необходимо вызывать для каждой добавляемой группировки строки.
	// УниверсальныйОтчет.ДобавитьИзмерениеСтроки(<ПутьКДанным>);
	
	УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Очистить();
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Организация");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Валюта");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Контрагент");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("ДоговорКонтрагента");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Сделка");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("СтавкаНДС");
	//
	// Добавление предопределенных группировок колонок отчета.
	// Необходимо вызывать для каждой добавляемой группировки колонки.
	УниверсальныйОтчет.ДобавитьИзмерениеКолонки("СобытиеНДС");
	
	// Добавление предопределенных отборов отчета.
	// Необходимо вызывать для каждого добавляемого отбора.
	// УниверсальныйОтчет.ДобавитьОтбор(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьОтбор("Организация");
	УниверсальныйОтчет.ДобавитьОтбор("Контрагент");
	УниверсальныйОтчет.ДобавитьОтбор("СобытиеНДС");

	//// Удалим добавляемые автоматически поля измерений
	//Сч=0;
	//Пока Сч < УниверсальныйОтчет.ПостроительОтчета.ВыбранныеПоля.Количество() Цикл

	//	Если (УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти(УниверсальныйОтчет.ПостроительОтчета.ВыбранныеПоля[Сч].Имя)<>Неопределено)
	//	 ИЛИ (УниверсальныйОтчет.ПостроительОтчета.ИзмеренияКолонки.Найти(УниверсальныйОтчет.ПостроительОтчета.ВыбранныеПоля[Сч].Имя)<>Неопределено) Тогда
	//		УниверсальныйОтчет.ПостроительОтчета.ВыбранныеПоля.Удалить(УниверсальныйОтчет.ПостроительОтчета.ВыбранныеПоля[Сч]);
	//	Иначе
	//		Сч=Сч+1;
	//	КонецЕсли;

	//КонецЦикла;
	
	// Установка связи подчиненных и родительских полей
	// УниверсальныйОтчет.УстановитьСвязьПолей(<ПутьКДанным>, <ПутьКДанным>);
	
	// Установка представлений полей
	// УниверсальныйОтчет.УстановитьПредставленияПолей(УниверсальныйОтчет.мСтруктураПредставлениеПолей, УниверсальныйОтчет.ПостроительОтчета);
	УниверсальныйОтчет.УстановитьПредставленияПолей(УниверсальныйОтчет.мСтруктураПредставлениеПолей, УниверсальныйОтчет.ПостроительОтчета);
	
	// Установка типов значений свойств в отборах отчета
	УниверсальныйОтчет.УстановитьТипыЗначенийСвойствДляОтбора();
	
	// Заполнение начальных настроек универсального отчета
	УниверсальныйОтчет.УстановитьНачальныеНастройки(Ложь);
	
	// Добавление дополнительных полей
	// Необходимо вызывать для каждого добавляемого дополнительного поля.
	// УниверсальныйОтчет.ДобавитьДополнительноеПоле(<ПутьКДанным>);
	
КонецПроцедуры // ЗаполнитьНачальныеНастройки()


// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//  ДокументРезультат - табличный документ, формируемый отчетом,
//  ПоказыватьЗаголовок - флаг того, показывать заголовок или скрывать его
//  ВысотаЗаголовка - возращаемое значение - высота заголовка
//  ТолькоЗаголовок - флаг того, сформировать только заголовок или весь отчет
//
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт

	СписокЗначенийСобытиеНДС = Новый СписокЗначений();
	
	Если    ВРЕГ(ВидОтчета) = ВРЕГ("РасчетыВозврат")
		ИЛИ НЕ ЗначениеЗаполнено(ВидОтчета) Тогда
		
		ВидОтчета = "РасчетыВозврат";
		
		СписокЗначенийСобытиеНДС.Добавить(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.Реализация);
		СписокЗначенийСобытиеНДС.Добавить(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.Возврат);
		
		// вставим группировки строк Валюта/Договор/контрагент, если их еще нет
		Индекс = 0;
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Организация") = Неопределено Тогда
			Индекс = УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Индекс(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Организация")) + 1;
		КонецЕсли;
		Если УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Валюта") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Вставить("Валюта",,,,,Индекс); 
			Индекс = Индекс + 1;
		КонецЕсли; 
		Если УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Контрагент") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Вставить("Контрагент",,,,,Индекс); 
			Индекс = Индекс + 1;
		КонецЕсли; 
		Если УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("ДоговорКонтрагента") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Вставить("ДоговорКонтрагента",,,,,Индекс); 
			Индекс = Индекс + 1;
		КонецЕсли; 
		
	ИначеЕсли ВРЕГ(ВидОтчета) = ВРЕГ("Розница") Тогда	
		
		СписокЗначенийСобытиеНДС.Добавить(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.РеализацияРозница);
		СписокЗначенийСобытиеНДС.Добавить(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.ВозвратРозница);
		
		//удалим группировки строк Договор/Контрагент
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("ДоговорКонтрагента") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("ДоговорКонтрагента")); 
		КонецЕсли; 
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Контрагент") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Контрагент")); 
		КонецЕсли; 
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Валюта") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Валюта")); 
		КонецЕсли; 
		
	ИначеЕсли ВРЕГ(ВидОтчета) = ВРЕГ("УсловнаяПродажа") Тогда	
		
		СписокЗначенийСобытиеНДС.Добавить(Перечисления.СобытияОжидаемыйИПодтвержденныйНДСПродаж.УсловнаяПродажа);
		
		//удалим группировки строк Договор/Контрагент
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("ДоговорКонтрагента") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("ДоговорКонтрагента")); 
		КонецЕсли; 
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Контрагент") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Контрагент")); 
		КонецЕсли; 
		Если НЕ УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Валюта") = Неопределено Тогда
			УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Удалить(УниверсальныйОтчет.ПостроительОтчета.ИзмеренияСтроки.Найти("Валюта")); 
		КонецЕсли; 
		
	КонецЕсли; 
	
	УниверсальныйОтчет.ПостроительОтчета.Отбор.СобытиеНДС.Использование = Истина;
	УниверсальныйОтчет.ПостроительОтчета.Отбор.СобытиеНДС.ВидСравнения  = ВидСравнения.ВСписке;
	УниверсальныйОтчет.ПостроительОтчета.Отбор.СобытиеНДС.Значение      = СписокЗначенийСобытиеНДС;
	
	
	// Перед формирование отчета можно установить необходимые параметры универсального отчета.
	УниверсальныйОтчет.СформироватьОтчет(ТабличныйДокумент);

КонецПроцедуры


Процедура ОбработкаРасшифровки(Расшифровка, Объект) Экспорт
	
	// Дополнительные параметры в расшифровывающий отчет можно перередать
	// посредством инициализации переменной "ДополнительныеПараметры".
	
	ДополнительныеПараметры = Неопределено;
	УниверсальныйОтчет.ОбработкаРасшифровкиУниверсальногоОтчета(Расшифровка, Объект, ДополнительныеПараметры);
	
КонецПроцедуры // ОбработкаРасшифровки()

// Формирует структуру для сохранения настроек отчета
//
Процедура СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками) Экспорт
	
	УниверсальныйОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками);
	
КонецПроцедуры // СформироватьСтруктуруДляСохраненияНастроек()

// Заполняет настройки отчета из структуры сохраненных настроек
//
Функция ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт
	
	Возврат УниверсальныйОтчет.ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ЭтотОбъект);
	
КонецФункции // ВосстановитьНастройкиИзСтруктуры()

#КонецЕсли

УниверсальныйОтчет.мРежимВводаПериода = 4; //месяц
