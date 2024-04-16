Перем мУдалятьДвижения, НаличиеДокументов;


Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
             	 
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры 

Процедура ОбработкаПроведения(Отказ,РежимПроведения)
	
    Если мУдалятьДвижения Тогда
        Движения.АрендаОС.Прочитать();                
        Для каждого Строка Из Движения.АрендаОС Цикл            
            НаличиеДокументов = Строка.НаличиеДокументов;            
        КонецЦикла;
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
    
    Если Отказ Тогда		
		Возврат;		
	КонецЕсли;

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	ПроверитьТабЧасть(Отказ);

	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство", "ОсновноеСредство");
    СтруктураПолей.Вставить("ИнвентарныйНомер", "ИнвентарныйНомер");
	
	РезультатЗапросаПоОС = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОсновныеСредства", СтруктураПолей);
	ТаблицаПоОС          = РезультатЗапросаПоОС.Выгрузить();
	СписокОС             = ТаблицаПоОС.ВыгрузитьКолонку("ОсновноеСредство");
	ТекОрганизация       = СтруктураШапкиДокумента.Организация;
	Упр                  = СтруктураШапкиДокумента.ОтражатьВУправленческомУчете;
	Бухг                 = СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете;
	
	//Проверка на наличие основных средств
	Запрос       = Новый Запрос;
	Запрос.УстановитьПараметр("ТекДата",        МоментВремени());
	Запрос.УстановитьПараметр("СписокОС",       СписокОС);
	Запрос.УстановитьПараметр("ТекОрганизация", ТекОрганизация);
	Запрос.Текст = "ВЫБРАТЬ" + ?(Упр,"
	|	МестонахождениеОС_УУ.ОсновноеСредство            КАК ОС_УУ", "") + ?(Бухг, ?(Упр, ",", "") + "
	|	МестонахождениеОС_БУ.ОсновноеСредство КАК ОС_БУ", "") + "
	|ИЗ" + ?(Упр,"
	|	РегистрСведений.МестонахождениеОС.СрезПоследних(&ТекДата, 
	|	                ОсновноеСредство В (&СписокОС)
	|	                ) КАК МестонахождениеОС_УУ", "") + ?(Упр и Бухг,"
	|		ПОЛНОЕ СОЕДИНЕНИЕ", "") + ?(Бухг,"
	|	РегистрСведений.МестонахождениеОСБухгалтерскийУчет.СрезПоследних(&ТекДата, 
	|	                ОсновноеСредство В (&СписокОС)
	|	                И Организация = &ТекОрганизация
	|	                ) КАК МестонахождениеОС_БУ", "") + ?(Упр и Бухг,"
	|		ПО МестонахождениеОС_УУ.ОсновноеСредство = МестонахождениеОС_БУ.ОсновноеСредство", "");
	
	ТаблицаОстатков = Запрос.Выполнить().Выгрузить();
	
	УправлениеВнеоборотнымиАктивами.ПроверитьДубли(ТаблицаПоОС, "Основные средства", "ОсновноеСредство", "Основное средство", Отказ, Заголовок);	
	
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС,Отказ, Заголовок);
	КонецЕсли;


КонецПроцедуры


Процедура ДвиженияПоРегистрамУпр(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)
	
	Если НЕ СтруктураШапкиДокумента.ОтражатьВУправленческомУчете Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ДатаДока = Дата;

	//УпрМестонахождениеОС = Движения.МестонахождениеОС;
	СобытиеОС	      = Движения.СобытияОС;

	Для каждого СтрокаТЧ Из ТаблицаПоОС Цикл
		
		//Движение = УпрМестонахождениеОС.Добавить();
		//Движение.Период           = ДатаДока;
		//Движение.ОсновноеСредство = СтрокаТЧ.ОсновноеСредство;
		//Движение.МОЛ              = СтруктураШапкиДокумента.МОЛ.ФизЛицо;
		//Движение.Местонахождение  = ПолучитьПодразделениеМОЛ(СтруктураШапкиДокумента.МОЛ);
		
		Движение = СобытиеОС.Добавить();
		Движение.Период            = ДатаДока;
		Движение.ОсновноеСредство  = СтрокаТЧ.ОсновноеСредство;
        Если ВидОперации = перечисления.ВидОперацийПередачаВАренду.ПередачаВАренду Тогда
            Движение.Событие       = Справочники.СобытияОС.Аренда;
        Иначе
            Движение.Событие       = Справочники.СобытияОС.НайтиПоКоду("000000011");
        КонецЕсли; 
		
		Движение.НазваниеДокумента = Метаданные().Представление();
		Движение.НомерДокумента    = Номер;
		
	КонецЦикла;
	//УпрМестонахождениеОС.Записать();
    СобытиеОС.Записать();
КонецПроцедуры

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС,Отказ, Заголовок)
    ДвиженияПоРегистрамУпр(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);
    ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);	
КонецПроцедуры // ДвиженияПоРегистрам

Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)
	
	Если НЕ СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ДатаДока = Дата;
	
	СобытиеОСБух             	 = Движения.СобытияОСОрганизаций;
	//МестонахождениеОСОрганизаций = Движения.МестонахождениеОСБухгалтерскийУчет;    
    АрендаОС                     = Движения.АрендаОС;    
    
    Для каждого СтрокаТЧ Из ТаблицаПоОС Цикл	
		//Движение = МестонахождениеОСОрганизаций.Добавить();
		//Движение.Период           = ДатаДока;
		//Движение.ОсновноеСредство = СтрокаТЧ.ОсновноеСредство;
		//Движение.Организация      = СтруктураШапкиДокумента.Организация;
		//Движение.МОЛ              = СтруктураШапкиДокумента.МОЛ.ФизЛицо;
		//Движение.Местонахождение  = ПолучитьПодразделениеМОЛ(СтруктураШапкиДокумента.МОЛ, Истина);
		
		Движение = СобытиеОСБух.Добавить();
		Движение.Период                   = ДатаДока;
		Движение.ОсновноеСредство         = СтрокаТЧ.ОсновноеСредство;
		Движение.Организация         	  = СтруктураШапкиДокумента.Организация;
        Если ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ПередачаВАренду Тогда
            Движение.Событие              = Справочники.СобытияОС.Аренда;
        Иначе
            Движение.Событие              = Справочники.СобытияОС.НайтиПоКоду("000000011");
        КонецЕсли; 
		
		Движение.НазваниеДокумента 		  = Метаданные().Представление();
		Движение.НомерДокумента    		  = Номер;
        Движение = АрендаОС.Добавить();
        Движение.Период                   = ДатаДока;
        
        Движение.Организация         	  = СтруктураШапкиДокумента.Организация;
        Движение.Контрагент               = СтруктураШапкиДокумента.Контрагент;
        Движение.БалансоваяСтоимость      = ОсновныеСредства.Найти(СтрокаТЧ.ОсновноеСредство,"ОсновноеСредство").БалансоваяСтоимость;
        Движение.Договор                  = СтруктураШапкиДокумента.Договор;
        Движение.МестонахождениеОС        = СтруктураШапкиДокумента.МестонахождениеОС;
        Движение.МОЛ                      = СтруктураШапкиДокумента.МОЛ;
        Движение.НаличиеДокументов        = НаличиеДокументов;
        Движение.ОсновноеСредство         = СтрокаТЧ.ОсновноеСредство;
        Движение.ИнвентарныйНомер         = СтрокаТЧ.ИнвентарныйНомер;
        Движение.Количество               = ОсновныеСредства.Найти(СтрокаТЧ.ОсновноеСредство,"ОсновноеСредство").Количество;
        Если ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ВозвратИзАренды Тогда
           Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
            //Движение.ВидОперации              = ВидОперации;
        Иначе
            //Движение.ОсновноеСредство         = Справочники.ОсновныеСредства.ПустаяСсылка();    
            Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
        КонецЕсли;
    КонецЦикла;
    СобытиеОСБух.Записать(); 
    //МестонахождениеОСОрганизаций.Записать();
    АрендаОС.Записать();	
КонецПроцедуры

Функция ПечатьАкта(ТипАкта)
    ТабДокумент   = Новый ТабличныйДокумент();
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Акт_передачи_в_Аренду";
	Макет         = ПолучитьМакет("Макет");
    ОбластьШапки = Макет.ПолучитьОбласть("Шапка");
    ЗаполнитьЗначенияСвойств(ОбластьШапки.Параметры, ЭтотОбъект);
    ОбластьШапки.Параметры.Организация = Организация.НаименованиеПолное;
    ОбластьШапки.Параметры.Контрагент =  Контрагент.НаименованиеПолное; 
    ОбластьШапки.Параметры.ДатаНомерДоговора = " №" + Договор.Номер + " от " + Формат(Договор.Дата, "ДФ=dd.MM.yyyy");
    ОбластьШапки.Параметры.СтрокаПередачи = "1. Представники Сторін оглянули Обладнання, що передається Орендарю від Орендодавця:";
    Если ТипАкта = "Возврат"  Тогда
    	ОбластьШапки.Параметры.СтрокаПередачи = "1. Представники Сторін оглянули Обладнання, що передається Орендодавцю від Орендаря";
    КонецЕсли; 
    ТабДокумент.Вывести(ОбластьШапки);
    ОбластьСтроки = Макет.ПолучитьОбласть("Тело");
    Для каждого Строка Из ОсновныеСредства Цикл
        ЗаполнитьЗначенияСвойств(ОбластьСтроки.Параметры, Строка);
        ТабДокумент.Вывести(ОбластьСтроки); 
    КонецЦикла; 
	ОбластьПодвала = Макет.ПолучитьОбласть("Подвал");
    Если типзнч(МестонахождениеОС) = Тип("Строка") Тогда
        ОбластьПодвала.Параметры.ТТАдрес = МестонахождениеОС;
    Иначе
        ОбластьПодвала.Параметры.ТТАдрес = МестонахождениеОС.Адрес;   
    КонецЕсли;
    ОбластьПодвала.Параметры.СтрокаПередачи2 = "2. Орендодавець здав, а Орендар прийняв Обладнання. Місцезнаходження обладнання:"; 
    ОбластьПодвала.Параметры.Кто1 = "Орендодавець";
    ОбластьПодвала.Параметры.Кто2 =  "Орендар"; 
    Если ТипАкта = "Возврат" Тогда
        ОбластьПодвала.Параметры.Кто1 = "Орендар";
        ОбластьПодвала.Параметры.Кто2 = "Орендодавець";
        ОбластьПодвала.Параметры.СтрокаПередачи2 = "2. Орендар здав, а Орендодавець прийняв Обладнання. Місцезнаходження обладнання:"; 
        ОбластьПодвала.Параметры.ТТАдрес = "";
    КонецЕсли; 
    ТабДокумент.Вывести(ОбластьПодвала);
    
    ТабДокумент.ОбластьПечати = ТабДокумент.Область(2, 2, ТабДокумент.ВысотаТаблицы, ТабДокумент.ШиринаТаблицы);
    
    Возврат ТабДокумент;  
КонецФункции
 

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт

	Если ЭтоНовый() Тогда
		Предупреждение("Документ можно распечатать только после его записи");
		Возврат;
	ИначеЕсли Не УправлениеДопПравамиПользователей.РазрешитьПечатьНепроведенныхДокументов(Проведен) Тогда
		Предупреждение("Недостаточно полномочий для печати непроведенного документа!");
		Возврат;
	КонецЕсли; 

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	// Получить экземпляр документа на печать
	Если ИмяМакета = "Передача" тогда
		ТабДокумент = ПечатьАкта("Передача");
	ИначеЕсли ИмяМакета = "Возврат" тогда
		ТабДокумент = ПечатьАкта("Возврат");
		
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли;
	
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект));

КонецПроцедуры // Печать

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	СтруктураМакетов = Новый Структура;

	Если  ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ПередачаВАренду тогда 
		СтруктураМакетов.Вставить("Передача","Акт передачи в аренду");
    Иначе
        СтруктураМакетов.Вставить("Возврат","Акт возврата из аренды");
	КонецЕсли;
	
	Возврат СтруктураМакетов;
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

Функция ПолучитьПодразделениеМОЛ(МОЛ, Регл=Ложь)
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    СоответствиеПодразделенийИПодразделенийОрганизаций.Подразделение,
                   |    РаботникиОрганизацийСрезПоследних.ПодразделениеОрганизации
                   |ИЗ
                   |    РегистрСведений.РаботникиОрганизаций.СрезПоследних(
                   |            ,
                   |            Сотрудник = &Сотрудник
                   |                И Организация = &Организация) КАК РаботникиОрганизацийСрезПоследних
                   |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СоответствиеПодразделенийИПодразделенийОрганизаций КАК СоответствиеПодразделенийИПодразделенийОрганизаций
                   |        ПО РаботникиОрганизацийСрезПоследних.ПодразделениеОрганизации = СоответствиеПодразделенийИПодразделенийОрганизаций.ПодразделениеОрганизации
                   |            И РаботникиОрганизацийСрезПоследних.Организация = СоответствиеПодразделенийИПодразделенийОрганизаций.Организация";
    Запрос.УстановитьПараметр("Сотрудник", МОЛ);
    Запрос.УстановитьПараметр("Организация", Организация);
    РезультатЗапроса = Запрос.Выполнить().Выбрать();
    Если РезультатЗапроса.Следующий()  Тогда
        Если Регл Тогда
            Возврат РезультатЗапроса.ПодразделениеОрганизации;    
        Иначе
            Возврат РезультатЗапроса.Подразделение;
        КонецЕсли; 
    	
    КонецЕсли; 
    
    Возврат Неопределено;
     
КонецФункции


Функция ПолучитьДанныеПоОС(ОС) Экспорт
    ВАренде = Ложь;
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    АрендаОСОстатки.ОсновноеСредство,
                   |    АрендаОСОстатки.КоличествоОстаток,
                   |    АрендаОСОстатки.БалансоваяСтоимостьОстаток
                   |ИЗ
                   |    РегистрНакопления.АрендаОС.Остатки(&Дата, ОсновноеСредство = &ОсновноеСредство) КАК АрендаОСОстатки
                   |ГДЕ
                   |    АрендаОСОстатки.КоличествоОстаток > 0";
    Запрос.УстановитьПараметр("ОсновноеСредство", ОС);
    Запрос.УстановитьПараметр("Дата", Дата);
    Если Запрос.Выполнить().Выбрать().Следующий() Тогда
    	ВАренде = Истина;
    КонецЕсли;     
    Запрос.Текст = "ВЫБРАТЬ
                   |    ПервоначальныеСведенияОСБухгалтерскийУчетСрезПоследних.ИнвентарныйНомер,
                   |    ПервоначальныеСведенияОСБухгалтерскийУчетСрезПоследних.ПервоначальнаяСтоимость,
                   |    СобытияОСОрганизацийСрезПоследних.Событие
                   |ИЗ
                   |    РегистрСведений.ПервоначальныеСведенияОСБухгалтерскийУчет.СрезПоследних(
                   |            ,
                   |            Организация = &Организация
                   |                И ОсновноеСредство = &ОсновноеСредство) КАК ПервоначальныеСведенияОСБухгалтерскийУчетСрезПоследних
                   |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СобытияОСОрганизаций.СрезПоследних КАК СобытияОСОрганизацийСрезПоследних
                   |        ПО ПервоначальныеСведенияОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство = СобытияОСОрганизацийСрезПоследних.ОсновноеСредство
                   |            И ПервоначальныеСведенияОСБухгалтерскийУчетСрезПоследних.Организация = СобытияОСОрганизацийСрезПоследних.Организация";
    Запрос.УстановитьПараметр("Организация", Организация);
    Запрос.УстановитьПараметр("ОсновноеСредство", ОС);
    РЗ = Запрос.Выполнить().Выбрать();
    Если РЗ.Следующий()  Тогда
    	Возврат Новый Структура("ИнвентарныйНомер, БалансоваяСтоимость, ВАренде", 
                                   РЗ.ИнвентарныйНомер, РЗ.ПервоначальнаяСтоимость, ВАренде);
    КонецЕсли; 
    Возврат Неопределено;
КонецФункции

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
    Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПередачаОСВаренду") 
        И ДанныеЗаполнения.ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ПередачаВАренду Тогда
        // Заполнение шапки
        ДатаПередачи = ДанныеЗаполнения.ДатаПередачи;
        Договор = ДанныеЗаполнения.Договор;
        Контрагент = ДанныеЗаполнения.Контрагент;
        МестонахождениеОС = ДанныеЗаполнения.МестонахождениеОС;
        МОЛ = ДанныеЗаполнения.МОЛ;
        Организация = ДанныеЗаполнения.Организация;
        ОтражатьВБухгалтерскомУчете = ДанныеЗаполнения.ОтражатьВБухгалтерскомУчете;
        ОтражатьВУправленческомУчете = ДанныеЗаполнения.ОтражатьВУправленческомУчете;
        ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ВозвратИзАренды;
        Для Каждого ТекСтрокаОсновныеСредства Из ДанныеЗаполнения.ОсновныеСредства Цикл
            НоваяСтрока = ОсновныеСредства.Добавить();
            НоваяСтрока.БалансоваяСтоимость = ТекСтрокаОсновныеСредства.БалансоваяСтоимость;
            НоваяСтрока.ИнвентарныйНомер = ТекСтрокаОсновныеСредства.ИнвентарныйНомер;
            НоваяСтрока.Количество = ТекСтрокаОсновныеСредства.Количество;
            НоваяСтрока.ОсновноеСредство = ТекСтрокаОсновныеСредства.ОсновноеСредство;
        КонецЦикла;
    КонецЕсли;
КонецПроцедуры


Процедура ПроверитьТабЧасть(Отказ)
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    МестонахождениеОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство
                   |ИЗ
                   |    РегистрСведений.МестонахождениеОСБухгалтерскийУчет.СрезПоследних(&Дата, Организация = &Организация) КАК МестонахождениеОСБухгалтерскийУчетСрезПоследних
                   |ГДЕ
                   |    МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ = &МОЛ";
    Запрос.УстановитьПараметр("Дата", Дата);
    Запрос.УстановитьПараметр("Организация", Организация);
    Запрос.УстановитьПараметр("МОЛ", МОЛ.Физлицо);
    СписокОС = Запрос.Выполнить().Выгрузить();
    Запрос.Текст = "ВЫБРАТЬ
                   |    АрендаОСОстатки.ОсновноеСредство,
                   |    АрендаОСОстатки.КоличествоОстаток,
                   |    АрендаОСОстатки.БалансоваяСтоимостьОстаток
                   |ИЗ
                   |    РегистрНакопления.АрендаОС.Остатки(&Дата, ОсновноеСредство В (&СписокОсновныхСредств)) КАК АрендаОСОстатки";     
    Запрос.УстановитьПараметр("СписокОсновныхСредств", ОсновныеСредства.ВыгрузитьКолонку("ОсновноеСредство"));
    СписокОСВАренде = Запрос.Выполнить().Выгрузить();
    Для каждого Строка Из ОсновныеСредства Цикл
        Если ЗначениеЗаполнено(Строка.ОсновноеСредство) Тогда
            СтрокаТЗ = СписокОС.Найти(Строка.ОсновноеСредство,"ОсновноеСредство");
            Если НЕ ЗначениеЗаполнено(СтрокаТЗ) Тогда
                Отказ = Истина;
                Сообщить(Строка.ОсновноеСредство.Наименование + " - данное ОС не принадлежит этой организации или МОЛ!");
                Прервать;	
            КонецЕсли;
            Если ВидОперации = Перечисления.ВидОперацийПередачаВАренду.ПередачаВАренду Тогда
                СтрокаТЗ = СписокОСВАренде.Найти(Строка.ОсновноеСредство,"ОсновноеСредство");
                Если ЗначениеЗаполнено(СтрокаТЗ) Тогда
                    Отказ = Истина;
                    Сообщить(Строка.ОсновноеСредство.Наименование + " - данное ОС уже находится в аренде!");
                    Прервать;	
                КонецЕсли;	
            КонецЕсли;            
        Иначе
            Отказ = Истина;
            Сообщить("Есть пустые строки в таблице ОС");
            Прервать;
        КонецЕсли; 
        
    КонецЦикла; 		
КонецПроцедуры
 
 