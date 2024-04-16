Перем СохраненнаяНастройка Экспорт;
Перем Расшифровки          Экспорт;
Перем ЭтоРасшифровка       Экспорт;

#Если Клиент ИЛИ ВнешнееСоединение Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Формирование отчета в табличный документ
// 
Функция СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина) Экспорт
	
	Возврат ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета);
	
КонецФункции //СформироватьОтчет()

// Доработка компоновщика перед выводом
//
Процедура ДоработатьКомпоновщикПередВыводом() Экспорт
	
	ЗначениеПараметра = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ЕстьГруппировкаПоПериодуРегисрации"));
	ЗначениеПараметра.Значение = ПрисутствуетПолеПериодРегистрацииВГруппировке();
	
	ДоработатьМакетОформленияПередВыводом();
	
	Если ЭтоРасшифровка тогда
		ЭлементВывода = КомпоновщикНастроек.Настройки.ПараметрыВывода.Элементы.Найти("VerticalOverallPlacement");
		ЭлементВывода.Использование = ложь;
	КонецЕсли;

КонецПроцедуры //ДоработатьКомпоновщикПередВыводом()


#КонецЕсли

#Если Клиент Тогда
	
// Настройка отчета
//
Процедура Настроить(Отбор, КомпоновщикНастроекОсновногоОтчета = Неопределено) Экспорт
	
	ТиповыеОтчеты.НастроитьТиповойОтчет(ЭтотОбъект, Отбор, КомпоновщикНастроекОсновногоОтчета);
	
КонецПроцедуры

// Сохранение настроек схемы компоновки
//
Процедура СохранитьНастройку() Экспорт
	
	СтруктураНастроек = ТиповыеОтчеты.ПолучитьСтруктуруПараметровТиповогоОтчета(ЭтотОбъект);
	СохранениеНастроек.СохранитьНастройкуОбъекта(СохраненнаяНастройка, СтруктураНастроек);
	
КонецПроцедуры

// Процедура заполняет параметры отчета по элементу справочника из переменной СохраненнаяНастройка.
//
Процедура ПрименитьНастройку() Экспорт
	
	Если СохраненнаяНастройка.Пустая() Тогда
		Возврат;
	КонецЕсли;
	 
	СтруктураПараметров = СохраненнаяНастройка.ХранилищеНастроек.Получить();
	ТиповыеОтчеты.ПрименитьСтруктуруПараметровОтчета(ЭтотОбъект, СтруктураПараметров);
	
КонецПроцедуры

// Инициализация отчета
//
Процедура ИнициализацияОтчета() Экспорт
	
	ТиповыеОтчеты.ИнициализацияТиповогоОтчета(ЭтотОбъект);
	
КонецПроцедуры //ИнициализацияОтчета()

#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

#Если Клиент ИЛИ ВнешнееСоединение Тогда
	
// Возвращает значение истина, если в элементах структур отчета присутствует поле Период регистрации
//
Функция ПрисутствуетПолеПериодРегистрацииВГруппировке()
	
	ЕстьГруппировка = ложь;
	
	Если КомпоновщикНастроек.Настройки.Структура.Количество() <> 0 тогда
		
		Если Тип(КомпоновщикНастроек.Настройки.Структура[0]) = Тип("ТаблицаКомпоновкиДанных") тогда
			
			ЕстьГруппировка = НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0].Строки[0]);
			
		ИначеЕсли Тип(КомпоновщикНастроек.Настройки.Структура[0]) = Тип("ГруппировкаКомпоновкиДанных") тогда
			
			ЕстьГруппировка = НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0]);
			
		ИначеЕсли Тип(КомпоновщикНастроек.Настройки.Структура[0]) = Тип("ДиаграммаКомпоновкиДанных") тогда
			
			Если КомпоновщикНастроек.Настройки.Структура[0].Точки.Количество() <> 0 тогда
				
				ЕстьГруппировка = НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0].Точки[0]) ИЛИ НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0].Серии[0]);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// найти поле группировки в отборе
	Для каждого ОтборПоле из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
		
		ПолеПериодРегистрации = Новый ПолеКомпоновкиДанных("ПериодРегистрации");
		
		Если ОтборПоле.Использование и (ОтборПоле.ЛевоеЗначение = ПолеПериодРегистрации или ОтборПоле.ПравоеЗначение = ПолеПериодРегистрации) тогда
			
			ЕстьГруппировка = истина;
			
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ЕстьГруппировка;
	
КонецФункции //ПрисутствуетПолеПериодРегистрацииВГруппировке()

Процедура ДоработатьМакетОформленияПередВыводом() 
	
	Если ЭтоРасшифровка тогда
		Возврат;
	КонецЕсли;
	
	Структура = КомпоновщикНастроек.Настройки.Структура;
	
	Пока Структура.Количество() > 0 Цикл
		
		Если Тип(Структура[0]) <> Тип("ГруппировкаКомпоновкиДанных") тогда
			Прервать;
		КонецЕсли;

		Структура = Структура[0];
		
		Если Структура.ПоляГруппировки.Элементы.Количество() > 0 
			 И Структура.ПоляГруппировки.Элементы[0].Поле <> Новый ПолеКомпоновкиДанных("Раздел") тогда
			 
			ЭлементУсловногоОформления = Структура.УсловноеОформление.Элементы.Добавить();
			ЭлементУсловногоОформления.Использование = истина;
			
			// добавим поля
			ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
			ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("Результат");
			
			ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
			ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("ОтработаноЧасов");
			
			ПолеОформления = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
			ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("ОтработаноДней");
			
			ПараметрТекст               = ЭлементУсловногоОформления.Оформление.Элементы.Найти("Text");
			ПараметрТекст.Значение      = Новый ПолеКомпоновкиДанных("РезультатНоль");
			ПараметрТекст.Использование = истина;
			
		Иначе
			Прервать;
		КонецЕсли;
		
		Структура = Структура.Структура;
		
	КонецЦикла;
	
КонецПроцедуры

// Функция возвращает значение истина, если в группировках элементов структуры присутствует поле "Период регистрации"
//
Функция НайтиПериодРегистрации(Структура)
	
	ЕстьПоле = ложь;
	
	Если ТипЗнч(Структура) <> Тип("ГруппировкаКомпоновкиДанных") тогда
		
		Возврат ЕстьПоле;
		
	КонецЕсли;
	
	ПолеПериодРегистрации = Новый ПолеКомпоновкиДанных("ПериодРегистрации");
	
	Для каждого ПолеГруппировки из Структура.ПоляГруппировки.Элементы Цикл
		
		Если ПолеГруппировки.Использование И ПолеГруппировки.Поле = ПолеПериодРегистрации тогда
			
			ЕстьПоле = истина;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если Не ЕстьПоле И Структура.Структура.Количество() <> 0 тогда
		
		ЕстьПоле = НайтиПериодРегистрации(Структура.Структура[0]);
		
	КонецЕсли;
	
	Возврат ЕстьПоле;
	
КонецФункции //НайтиПериодРегистрации()

ЭтоРасшифровка = ложь;

#КонецЕсли

#Если Клиент Тогда

Расшифровки = Новый СписокЗначений;

НастройкаПериода = Новый НастройкаПериода;

#КонецЕсли
