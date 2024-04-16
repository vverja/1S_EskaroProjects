Перем мДатаСведений Экспорт;

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой инвентарной карточки ОС (форма ОС-6)
// Возвращаемое значение:
// Табличный документ - печатная форма инвентарной карточки ОС
Функция ПечатьОЗ6(ДатаСведений,ПечатьПоДаннымУпрУчета = Истина) 
	
	Макет    = ПолучитьМакет("ОЗ6");
	Шапка						= Макет.ПолучитьОбласть("Шапка");
	ШапкаМодернизацииИРемонта	= Макет.ПолучитьОбласть("ШапкаМодернизацииИРемонта");
	СтрокаМодернизацииИРемонта 	= Макет.ПолучитьОбласть("СтрокаМодернизацииИРемонта");
	Подвал						= Макет.ПолучитьОбласть("Подвал");

	ТабДок = Новый ТабличныйДокумент();
	НазваниеРегистраСтоимость = "СтоимостьОС";
	НазваниеРегистраСобытия   = "СобытияОС";
	НазваниеСуммыЗатрат		  = "СуммаЗатрат";	
	Организация               = Неопределено;
	ИнвентарныйНомер          = "";

	Если ПечатьПоДаннымУпрУчета тогда
		
		cВидаУчета   = "Управлінський";        
		ВалютаПечати = глЗначениеПеременной("ВалютаУправленческогоУчета").Наименование;
		ВидУчета 	 = "Упр" ;
		
	Иначе
		
		cВидаУчета   = "Бухгалтерський";
		ВалютаПечати = глЗначениеПеременной("ВалютаРегламентированногоУчета").Наименование;
		НазваниеРегистраСтоимость = НазваниеРегистраСтоимость + "БухгалтерскийУчет";
		НазваниеРегистраСобытия   = НазваниеРегистраСобытия   + "Организаций";
		НазваниеСуммыЗатрат		  = НазваниеСуммыЗатрат +"БУ";
		ВидУчета 	 = "Бух";
		ВыборкаЗаписей = РегистрыСведений.ПервоначальныеСведенияОСБухгалтерскийУчет.ПолучитьПоследнее(ДатаСведений,Новый Структура("ОсновноеСредство",Ссылка));
		
		Если ВыборкаЗаписей.Количество() > 0 Тогда
			
			Организация              = ВыборкаЗаписей.Организация;
			СтруктураКодыОрганизаций = Новый Структура("Организация", Организация);
			СтруктураКодыОрганизаций = РегистрыСведений.КодыОрганизации.ПолучитьПоследнее(, СтруктураКодыОрганизаций);
			Шапка.Параметры.ЕДРПОУ	 = СтруктураКодыОрганизаций.КодПоЕДРПОУ;
			
		Иначе
			
			Организация = Справочники.Организации.ПустаяСсылка();
			
		КонецЕсли;

	КонецЕсли;	
	
	СведенияОбОС = УправлениеВнеоборотнымиАктивами.ПолучитьСведенияОбОС(Ссылка,ДатаСведений,Организация,ВидУчета); 
	
	Если СведенияОбОС <> Неопределено тогда
		
		Если Не ПечатьПоДаннымУпрУчета и НЕ ЗначениеЗаполнено(СведенияОбОС.ОсновноеСредство) Тогда
			
			Сообщить("На момент печати основное средство не принималось к учету в указанной организации."+Символы.ПС+
			"Нельзя сформировать инвентарную карточку объекта!",СтатусСообщения.Внимание);
			Возврат Неопределено;
			
		КонецЕсли;
		
		Шапка.Параметры.Заполнить(СведенияОбОС);
		Шапка.Параметры.НаименованиеОС = ? (НЕ ЗначениеЗаполнено(СведенияОбОС.НаименованиеПолное),
		                                    СведенияОбОС.Наименование, СведенияОбОС.НаименованиеПолное);
											
															 
		СтрокаМодернизацииИРемонта.Параметры.ИнвентарныйНомер = СведенияОбОС.ИнвентарныйНомер;
		
		Если ПечатьПоДаннымУпрУчета Тогда
			
			Шапка.Параметры.Организация	= "Управлінський облік";
			
		Иначе
						
			Шапка.Параметры.Организация = ? (НЕ ЗначениеЗаполнено(СведенияОбОС.ОрганизацияНаименованиеПолное),
			                                 СведенияОбОС.ОрганизацияНаименование, СведенияОбОС.ОрганизацияНаименованиеПолное);
			
			Шапка.Параметры.КодСчетаИАналитикиПоАмортизации = "" + СведенияОбОС.СчетНачисленияАмортизации +"; " 
			                                                     + СведенияОбОС.НаправленияАмортизацииКод;
																 
		КонецЕсли;
		
	Иначе
		
		Сообщить("На момент печати основное средство не принималось к учету."+Символы.ПС+
		"Нельзя сформировать инвентарную карточку объекта!",СтатусСообщения.Внимание);
		Возврат Неопределено;
		
	КонецЕсли;
	
	// получим даты  и документы изменения состояний ос
	СтруктПараметров = УправлениеВнеоборотнымиАктивами.ПолучитьАтрибутыСостоянияОС(Ссылка, Перечисления.СостоянияОС.ПринятоКУчету,ПечатьПоДаннымУпрУчета,Организация);
	Шапка.Параметры.ДокументПоступленияНомер = СтруктПараметров["НомерДок"];
	Шапка.Параметры.ДокументПоступленияДата	 = СтруктПараметров["Дата"];
	
	СтруктПараметров = УправлениеВнеоборотнымиАктивами.ПолучитьАтрибутыСостоянияОС(Ссылка, Перечисления.СостоянияОС.ВведеноВЭксплуатацию,ПечатьПоДаннымУпрУчета,Организация);
	Шапка.Параметры.ДокументВводаВЭксплуатациюНомер	= СтруктПараметров["НомерДок"];
	Шапка.Параметры.ДокументВводаВЭксплуатациюДата	= СтруктПараметров["Дата"];
	
	СтруктПараметров = УправлениеВнеоборотнымиАктивами.ПолучитьАтрибутыСостоянияОС(Ссылка, Перечисления.СостоянияОС.СнятоСУчета,ПечатьПоДаннымУпрУчета,Организация);
	Шапка.Параметры.ДокументВыбытияНомер = СтруктПараметров["НомерДок"];
	Шапка.Параметры.ДокументВыбытияДата	 = СтруктПараметров["Дата"];
	
	Шапка.Параметры.Валюта     = ВалютаПечати;
	Шапка.Параметры.cВидаУчета = cВидаУчета;
	
	ТабДок.Вывести(Шапка);

	// Модернизация ОС и ремонт
	ТаблицаМодернизаций = Новый ТаблицаЗначений;
	ТаблицаМодернизаций.Колонки.Добавить("Дата");
	ТаблицаМодернизаций.Колонки.Добавить("Номер");
	ТаблицаМодернизаций.Колонки.Добавить("Сумма");
	
	ТаблицаРемонтов = Новый ТаблицаЗначений;
	ТаблицаРемонтов.Колонки.Добавить("Дата");
	ТаблицаРемонтов.Колонки.Добавить("Номер");
	ТаблицаРемонтов.Колонки.Добавить("Сумма");
	
	ШапкаМодернизацииИРемонта.Параметры.Валюта     = ВалютаПечати;
	ШапкаМодернизацииИРемонта.Параметры.cВидаУчета = cВидаУчета;
	ТабДок.Вывести(ШапкаМодернизацииИРемонта);
	
	Запрос = Новый Запрос;	
	Запрос.УстановитьПараметр("ОсновноеСредство"   , Ссылка);
	Запрос.УстановитьПараметр("ДатаСведений"       , ДатаСведений);
	Запрос.УстановитьПараметр("УсловиеМодернизаций", Перечисления.ВидыСобытийОС.Модернизация);
	Запрос.УстановитьПараметр("УсловиеРемонтов"    , Перечисления.ВидыСобытийОС.Ремонт);
	Запрос.УстановитьПараметр("ВидОперацииОС"      , Перечисления.ВидыСобытийОС.ПринятиеКУчету);
	
	Если Не ПечатьПоДаннымУпрУчета Тогда
		
		Запрос.УстановитьПараметр("Организация", Организация);
		
	КонецЕсли;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(ВЫБОР КОГДА ОперацииОС.Событие.ВидСобытияОС = (&УсловиеМодернизаций) 
	|		  ТОГДА ОперацииОС."+НазваниеСуммыЗатрат+" ИНАЧЕ 0 КОНЕЦ) КАК СуммаЗатратМодернизаций,
	|	СУММА(ВЫБОР КОГДА ОперацииОС.Событие.ВидСобытияОС = (&УсловиеРемонтов) 
	|		  ТОГДА ОперацииОС."+НазваниеСуммыЗатрат+" ИНАЧЕ 0 КОНЕЦ) КАК СуммаЗатратРемонтов,
	|	ОперацииОС.Регистратор       КАК Регистратор,
	|	ОперацииОС.Период            КАК Период,
	|	ОперацииОС.Событие           КАК Операция,
	|	ОперацииОС.НомерДокумента    КАК НомерДокумента,
	|	ОперацииОС.НазваниеДокумента КАК НазваниеДокумента
	|ИЗ
	|	РегистрСведений."+НазваниеРегистраСобытия+" КАК ОперацииОС
	|
	|ГДЕ
	|	ОперацииОС.Событие.ВидСобытияОС <> &ВидОперацииОС
	|	И ОперацииОС.Период < &ДатаСведений
	|	И ОперацииОС.ОсновноеСредство = &ОсновноеСредство" + ?(Не ПечатьПоДаннымУпрУчета, "
	|	И ОперацииОС.Организация = &Организация", "") + "
	|
	|СГРУППИРОВАТЬ ПО
	|	ОперацииОС.Период,
	|	ОперацииОС.Регистратор,
	|	ОперацииОС.Событие,
	|	ОперацииОС.НомерДокумента,
	|	ОперацииОС.НазваниеДокумента
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период,
	|	Регистратор";
	Результат = Запрос.Выполнить();
	
	
	СпособВыборки = ОбходРезультатаЗапроса.ПоГруппировкам;
	ВыборкаРегистраторов = Результат.Выбрать(СпособВыборки);
	
	Пока ВыборкаРегистраторов.Следующий() Цикл
		
		СуммаМодернизаций = ОбщегоНазначения.ПреобразоватьВЧисло(ВыборкаРегистраторов.СуммаЗатратМодернизаций);
		СуммаРемонтов     = ОбщегоНазначения.ПреобразоватьВЧисло(ВыборкаРегистраторов.СуммаЗатратРемонтов);
		
		Если СуммаМодернизаций <> 0 Тогда		
			
			СтрокаТаблицыМодернизаций = ТаблицаМодернизаций.Добавить();
			СтрокаТаблицыМодернизаций.Номер = ВыборкаРегистраторов.НомерДокумента;
			СтрокаТаблицыМодернизаций.Дата  = ВыборкаРегистраторов.Период;
			СтрокаТаблицыМодернизаций.Сумма = СуммаМодернизаций;
			
		КонецЕсли;
		
		Если СуммаРемонтов <> 0 Тогда		
			
			СтрокаТаблицыРемонтов = ТаблицаРемонтов.Добавить();
			СтрокаТаблицыРемонтов.Номер = ВыборкаРегистраторов.НомерДокумента;
			СтрокаТаблицыРемонтов.Дата  = ВыборкаРегистраторов.Период;
			СтрокаТаблицыРемонтов.Сумма = СуммаРемонтов;
			
		КонецЕсли;
		
	КонецЦикла;
	
	КоличествоСтрокМодернизации = ТаблицаМодернизаций.Количество();
	КоличествоСтрокРемонтов     = ТаблицаРемонтов.Количество();
	КоличествоСтрок             = Макс(КоличествоСтрокМодернизации, 
	                                   Окр(КоличествоСтрокРемонтов / 2, 0, РежимОкругления.Окр15как20));
	СчетСтрокРемонтов           = 0;
	
	Для СчетСтрок = 0 По КоличествоСтрок-1 Цикл
		
		// строка модернизации
		Если СчетСтрок < КоличествоСтрокМодернизации Тогда
			
			СтрокаТаблицы = ТаблицаМодернизаций.Получить(СчетСтрок);
			СтрокаМодернизацииИРемонта.Параметры.ДатаМодернизации  = СтрокаТаблицы.Дата;
			СтрокаМодернизацииИРемонта.Параметры.НомерМодернизации = СтрокаТаблицы.Номер;
			СтрокаМодернизацииИРемонта.Параметры.СуммаМодернизации = СтрокаТаблицы.Сумма; 
			
		Иначе
			
			СтрокаМодернизацииИРемонта.Параметры.ДатаМодернизации  = "";
			СтрокаМодернизацииИРемонта.Параметры.НомерМодернизации = "";
			СтрокаМодернизацииИРемонта.Параметры.СуммаМодернизации = ""; 
			
		КонецЕсли;
		
		// первая подстрока ремонта
		Если СчетСтрокРемонтов < КоличествоСтрокРемонтов Тогда
			
			СтрокаМодернизации = ТаблицаРемонтов.Получить(СчетСтрокРемонтов);			
			СтрокаМодернизацииИРемонта.Параметры.ДатаРемонта  = СтрокаМодернизации.Дата;
			СтрокаМодернизацииИРемонта.Параметры.НомерРемонта = СтрокаМодернизации.Номер;
			СтрокаМодернизацииИРемонта.Параметры.СуммаРемонта = СтрокаМодернизации.Сумма;
			СчетСтрокРемонтов = СчетСтрокРемонтов + 1;
			
		Иначе
			
			СтрокаМодернизацииИРемонта.Параметры.ДатаРемонта  = "";
			СтрокаМодернизацииИРемонта.Параметры.НомерРемонта = "";
			СтрокаМодернизацииИРемонта.Параметры.СуммаРемонта = "";
			
		КонецЕсли;
		
		// вторая подстрока ремонта
		Если СчетСтрокРемонтов < КоличествоСтрокРемонтов Тогда
			
			СтрокаМодернизации = ТаблицаРемонтов.Получить(СчетСтрокРемонтов);
			СтрокаМодернизацииИРемонта.Параметры.ДатаРемонта1  = СтрокаМодернизации.Дата;
			СтрокаМодернизацииИРемонта.Параметры.НомерРемонта1 = СтрокаМодернизации.Номер;
			СтрокаМодернизацииИРемонта.Параметры.СуммаРемонта1 = СтрокаМодернизации.Сумма;
			СчетСтрокРемонтов = СчетСтрокРемонтов + 1;
			
		Иначе
			
			СтрокаМодернизацииИРемонта.Параметры.ДатаРемонта1  = "";
			СтрокаМодернизацииИРемонта.Параметры.НомерРемонта1 = "";
			СтрокаМодернизацииИРемонта.Параметры.СуммаРемонта1 = "";
			
		КонецЕсли;
		
		ТабДок.Вывести(СтрокаМодернизацииИРемонта);		
		
	КонецЦикла;
	
	Подвал.Параметры.ДатаЗаполнения = ДатаСведений;
	ТабДок.Вывести(Подвал);		
	
	ТабДок.АвтоМасштаб = Истина;
	ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	ТабДок.ПолеСлева  = 5;
	ТабДок.ПолеСправа = 5;
	ТабДок.ПолеСверху = 0;
	ТабДок.ПолеСнизу  = 0;
	ТабДок.ИмяПараметровПечати = "КарточкаОЗ6";
	УниверсальныеМеханизмы.НапечататьДокумент(ТабДок, , , "Инвентарная карточка ОС (Форма ОЗ-6)");
	
КонецФункции // ПечатьОС6_2003() 
  
////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Процедура осуществляет печать справочника. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
// Параметры:
//  НазваниеМакета - строка, название макета.
// Возвращаемое значение:
//  Нет.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, ФормаЭлемента = Неопределено) Экспорт

	Если ЭтоНовый() Тогда
		Предупреждение("Справочник можно распечатать только после его записи");
		Возврат;
	КонецЕсли; 

	Если Не ПроверитьМодифицированностьСправочника(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;
	
	ДатаСведений = ?(мДатаСведений = Неопределено, КонецДня(ОбщегоНазначения.ПолучитьРабочуюДату()), мДатаСведений);
	
	// Получить экземпляр документа на печать
	Если ИмяМакета = "ОЗ6упр" Тогда
		
		ТабДокумент = ПечатьОЗ6(ДатаСведений);
		
	ИначеЕсли ИмяМакета = "ОЗ6бух" Тогда
		
		ТабДокумент = ПечатьОЗ6(ДатаСведений, Ложь);
		
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Инвентарная карточка ОС (Форма ОС-6)");

КонецПроцедуры // Печать()
  

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	СтруктураМакетов = Новый Структура;
	
	СтруктураМакетов.Вставить("ОЗ6упр","Форма ОЗ-6(упр. учет)");	
	СтруктураМакетов.Вставить("ОЗ6бух","Форма ОЗ-6(бух. учет)");
	 
	Возврат СтруктураМакетов;
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()


// Проверяет модифицированность справочника перед печатью, и если необходимо 
// записывает его
// 
// Параметры
//  ЭлементСправочника - (СправочникОбъект.*) - проверяемый элемент справочника
//
Функция ПроверитьМодифицированностьСправочника(ЭлементСправочника)

	Результат = Ложь;

	Если ЭлементСправочника.Модифицированность() Тогда

		Ответ = Вопрос("Элемент справочника изменен. Для печати его необходимо записать.
		               |Записать?",
		               РежимДиалогаВопрос.ОКОтмена, , 
		               КодВозвратаДиалога.Отмена,
		               "Элемент справочника изменен");

		Если Ответ = КодВозвратаДиалога.ОК Тогда

			ЭлементСправочника.Записать();
			Результат = Истина;

		КонецЕсли;

	Иначе
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;

КонецФункции // ПроверитьМодифицированностьСправочника()

#КонецЕсли


//////////////////////////////////////////////////////////////////////////////////
//// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если ТипЗнч(Основание) = Тип("СправочникСсылка.ОбъектыСтроительства") Тогда
		
		// Заполнение шапки
		Наименование       = Основание.Наименование;
		НаименованиеПолное = Основание.Наименование;
		
	ИначеЕсли ТипЗнч(Основание) = Тип("СправочникСсылка.Номенклатура") Тогда
		
		// Заполнение шапки
		Наименование       = Основание.Наименование;
		НаименованиеПолное = Основание.НаименованиеПолное;
		
	КонецЕсли;
	
КонецПроцедуры
