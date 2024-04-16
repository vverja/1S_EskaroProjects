////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

Перем ЭлементыНастройки    Экспорт; // Массив элементов структуры СКД         
Перем СохраненнаяНастройка Экспорт; 
Перем Расшифровки          Экспорт; 

#Если Клиент Тогда

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Сохранение настроек схемы компоновки
//
Процедура СохранитьНастройку() Экспорт
	
	СтруктураНастроек = ТиповыеОтчеты.ПолучитьСтруктуруПараметровТиповогоОтчета(ЭтотОбъект);
	СохранениеНастроек.СохранитьНастройкуОбъекта(СохраненнаяНастройка, СтруктураНастроек);
	
КонецПроцедуры

// Инициализация отчета
//
// Параметры:
//  Нет.
//
Процедура ИнициализацияОтчета() Экспорт
	
	ТиповыеОтчеты.ИнициализацияТиповогоОтчета(ЭтотОбъект);
	
КонецПроцедуры //ИнициализацияОтчета()


// Заполнение параметров отчета по элементу справочника из переменной СохраненнаяНастройка.
//
Процедура ПрименитьНастройку() Экспорт
	
	Если СохраненнаяНастройка.Пустая() Тогда
		Возврат;
	КонецЕсли;
	 
	СтруктураПараметров = СохраненнаяНастройка.ХранилищеНастроек.Получить();
	ТиповыеОтчеты.ПрименитьСтруктуруПараметровОтчета(ЭтотОбъект, СтруктураПараметров);
	
КонецПроцедуры

// Формирование отчета в табличный документ
// 
Функция СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = истина) Экспорт
	
	Если ДанныеРасшифровки = Неопределено тогда
		ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных;
	КонецЕсли;
	
	Возврат ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета);
	
КонецФункции

// Настройка отчета 
//
Процедура Настроить(Отбор, КомпоновщикНастроекОсновногоОтчета = Неопределено) Экспорт
	
	ТиповыеОтчеты.НастроитьТиповойОтчет(ЭтотОбъект, Отбор, КомпоновщикНастроекОсновногоОтчета);
	
КонецПроцедуры


// Запоминание элементов структуры отчета компоновщика настроек
//
Процедура ЗапомнитьНастройку() Экспорт 
	
	Если КомпоновщикНастроек.Настройки.Структура.Количество() <> 0 тогда
		Если ТипЗнч(КомпоновщикНастроек.Настройки.Структура[0]) <> Тип("ТаблицаКомпоновкиДанных") тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ЭлементыНастройки[0] = КомпоновщикНастроек.Настройки.Структура[0].Колонки[0];
	ЭлементыНастройки[1] = КомпоновщикНастроек.Настройки.Структура[0].Колонки[1];
	ЭлементыНастройки[2] = КомпоновщикНастроек.Настройки.Структура[0].Колонки[2];
	ЭлементыНастройки[3] = КомпоновщикНастроек.Настройки.Структура[0].Колонки[1].Структура[0];
	
	КомпоновщикНастроек.Настройки.Структура[0].Колонки.Удалить(ЭлементыНастройки[0]);
	КомпоновщикНастроек.Настройки.Структура[0].Колонки.Удалить(ЭлементыНастройки[1]);
	КомпоновщикНастроек.Настройки.Структура[0].Колонки.Удалить(ЭлементыНастройки[2]);
	
КонецПроцедуры

// Добавление настройки структуры в колонки таблицы
//
Процедура ВосстановитьНастройку() Экспорт  
	
	Если КомпоновщикНастроек.Настройки.Структура.Количество() <> 0 тогда
		Если ТипЗнч(КомпоновщикНастроек.Настройки.Структура[0]) <> Тип("ТаблицаКомпоновкиДанных") тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ЭлементГруппировки = КомпоновщикНастроек.Настройки.Структура[0].Колонки.Добавить();
	ТиповыеОтчеты.СкопироватьНастройкиКомпоновкиДанных(ЭлементГруппировки, ЭлементыНастройки[0]);
	
	ЭлементГруппировки = КомпоновщикНастроек.Настройки.Структура[0].Колонки.Добавить();
	ТиповыеОтчеты.СкопироватьНастройкиКомпоновкиДанных(ЭлементГруппировки, ЭлементыНастройки[1]);
	
	//ЭлементГруппировки = ЭлементГруппировки.Структура.Добавить();
	//ТиповыеОтчеты.СкопироватьНастройкиКомпоновкиДанных(ЭлементГруппировки, ЭлементыНастройки[3]);
	
	ЭлементГруппировки = КомпоновщикНастроек.Настройки.Структура[0].Колонки.Добавить();
	ТиповыеОтчеты.СкопироватьНастройкиКомпоновкиДанных(ЭлементГруппировки, ЭлементыНастройки[2]);
	
КонецПроцедуры

// Доработка компоновщика отчета перед выводом
//

Процедура ДоработатьКомпоновщикПередВыводом() Экспорт
	
	ЗначениеПараметра = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ЕстьГруппировкаПоПериодуРегисрации"));
	ЗначениеПараметра.Значение = ПрисутствуетПолеПериодРегистрацииВГруппировке();
	
	ЗначениеПараметра.Использование = Истина;
	
	// Если в выбранные поля добавлены поле нумерации в группе или сквозной нумерации в группе перенесем данные 
	// поля в самую нижнюю группировку строк отчета.
	ГруппировкаДляВремени = Неопределено;
	УдаляемыеПоля = Новый Массив;
	
	Для каждого ВыбранноеПоле из КомпоновщикНастроек.Настройки.Выбор.Элементы Цикл
		Если ТипЗнч(ВыбранноеПоле) <> Тип("ГруппаВыбранныхПолейКомпоновкиДанных") тогда
			Если ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.НомерПоПорядкуВГруппировке") или ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("SystemFields.GroupSerialNumber") тогда
				ПоследнийЭлементСтруктуры = НайтиПоследнийЭлементСтруктурыСтрок(КомпоновщикНастроек.Настройки.Структура[0].Строки);
				Если ПоследнийЭлементСтруктуры <> Неопределено тогда
					ЭлементВыбранногоПоля = ПоследнийЭлементСтруктуры.Выбор.Элементы.Вставить(0,Тип("ВыбранноеПолеКомпоновкиДанных"));
					ЭлементВыбранногоПоля.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.НомерПоПорядкуВГруппировке");
				КонецЕсли;
				
			ИначеЕсли ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.НомерПоПорядку") или ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("SystemFields.SerialNumber") тогда
				ПоследнийЭлементСтруктуры = НайтиПоследнийЭлементСтруктурыСтрок(КомпоновщикНастроек.Настройки.Структура[0].Строки);
				Если ПоследнийЭлементСтруктуры <> Неопределено тогда
					ЭлементВыбранногоПоля = ПоследнийЭлементСтруктуры.Выбор.Элементы.Вставить(0,Тип("ВыбранноеПолеКомпоновкиДанных"));
					ЭлементВыбранногоПоля.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.НомерПоПорядку");
				КонецЕсли;
				
			ИначеЕсли ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.Уровень") ИЛИ ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("SystemFields.Level") Тогда
				ПоследнийЭлементСтруктуры = НайтиПоследнийЭлементСтруктурыСтрок(КомпоновщикНастроек.Настройки.Структура[0].Строки);
				Если ПоследнийЭлементСтруктуры <> Неопределено Тогда
					ЭлементВыбранногоПоля = ПоследнийЭлементСтруктуры.Выбор.Элементы.Вставить(0,Тип("ВыбранноеПолеКомпоновкиДанных"));
					ЭлементВыбранногоПоля.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.Уровень");
				КонецЕсли;
				
			ИначеЕсли ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("СистемныеПоля.УровеньВГруппе") ИЛИ ВыбранноеПоле.Поле = Новый ПолеКомпоновкиДанных("SystemFields.LevelInGroup") Тогда
				ПоследнийЭлементСтруктуры = НайтиПоследнийЭлементСтруктурыСтрок(КомпоновщикНастроек.Настройки.Структура[0].Строки);
				Если ПоследнийЭлементСтруктуры <> Неопределено Тогда
					ЭлементВыбранногоПоля = ПоследнийЭлементСтруктуры.Выбор.Элементы.Вставить(0, Тип("ВыбранноеПолеКомпоновкиДанных"));
					ЭлементВыбранногоПоля.Поле = Новый ПолеКомпоновкиДанных("SystemFields.LevelInGroup");
				КонецЕсли;		
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Если ГруппировкаДляВремени <> Неопределено тогда
		Для каждого ПолеВыбора из УдаляемыеПоля Цикл
			КомпоновщикНастроек.Настройки.Выбор.Элементы.Удалить(ПолеВыбора);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Функция НайтиПоследнийЭлементСтруктурыСтрок(Строки) 
		
	Если Строки.Количество() = 0 тогда
		Возврат Неопределено;
	Иначе
		ЭлементСтруктуры = Строки[0];
	КонецЕсли;
	Пока ЭлементСтруктуры.Структура.Количество() <> 0 Цикл
		ЭлементСтруктуры = ЭлементСтруктуры.Структура[0];
	КонецЦикла;
	
	Возврат ЭлементСтруктуры;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ
Процедура УстановитьПараметрыПодписиОтветственныхЛиц() Экспорт

	ЕстьОтборПоОрганизации = Ложь;
	
	Для Каждого ЭлементОтбора ИЗ КомпоновщикНастроек.ПолучитьНастройки().Отбор.Элементы Цикл
		Если ТипЗнч(ЭлементОтбора.ПравоеЗначение) <> Тип("СправочникСсылка.Организации") Тогда
			Продолжить;
		Иначе
			Если ЗначениеЗаполнено(ЭлементОтбора.ПравоеЗначение) И ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно И ЭлементОтбора.Использование = Истина Тогда
				ЕстьОтборПоОрганизации = Истина;
			КонецЕсли;
		КонецЕсли;	
	КонецЦикла;
	
	СписокОтветственных = Новый СписокЗначений;
	СписокОтветственных.Добавить(Перечисления.ОтветственныеЛицаОрганизаций.ГлавныйБухгалтер);
	СписокОтветственных.Добавить(Перечисления.ОтветственныеЛицаОрганизаций.Руководитель);
	ТребуемыеОтветсвенныеЛица = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамТребуемыеОтвественныеЛица"));
	ТребуемыеОтветсвенныеЛица.Значение = СписокОтветственных;
	ТребуемыеОтветсвенныеЛица.Использование = Истина;
	
	ВыводитьПодписиОтветственных = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ВыводитьПодписиОтветственныхЛицВОтчетеРасчетнаяВедомостьОрганизаций"));
	Если ЕстьОтборПоОрганизации Тогда
		ВыводитьПодписиОтветственных.Значение = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ВыводитьПодписиОтветственныхЛицВОтчетеРасчетнаяВедомостьОрганизации");
	Иначе
		ВыводитьПодписиОтветственных.Значение = Ложь;
	КонецЕсли;
	ВыводитьПодписиОтветственных.Использование = Истина;
КонецПроцедуры


// Возвращает значение истина, если в элементах структур отчета присутствует поле Период регистрации
//
Функция ПрисутствуетПолеПериодРегистрацииВГруппировке()
	
	Если КомпоновщикНастроек.Настройки.Структура.Количество() <> 0 тогда
		
		Если Тип(КомпоновщикНастроек.Настройки.Структура[0]) = Тип("ТаблицаКомпоновкиДанных") тогда
			
			Возврат НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0].Строки[0]);
			
		ИначеЕсли Тип(КомпоновщикНастроек.Настройки.Структура[0]) = Тип("ГруппировкаКомпоновкиДанных") тогда
			
			Возврат НайтиПериодРегистрации(КомпоновщикНастроек.Настройки.Структура[0]);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ложь;
	
КонецФункции //ПрисутствуетПолеПериодРегистрацииВГруппировке()

// Функция возвращает значение истина, если в группировках элементов структуры присутствует поле "Период регистрации"
//
Функция НайтиПериодРегистрации(Структура)
	
	ЕстьПоле = ложь;
	
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

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

Расшифровки = Новый СписокЗначений;

ЭлементыНастройки = Новый Массив(4);

НастройкаПериода = Новый НастройкаПериода;

#КонецЕсли
