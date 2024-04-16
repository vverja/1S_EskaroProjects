#Если Клиент Тогда

Перем ИмяРегистраБухгалтерии Экспорт;
Перем МаксКоличествоСубконто Экспорт;


//////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ЗАГОЛОВКА ОТЧЕТА
//

Функция ЗаголовокОтчета() Экспорт
	Возврат "Обороты между субконто (налоговый)";
КонецФункции // ЗаголовокОтчета()

// Функция возвращает строку описания настроек отборов
//
// Параметры
//  Нет параметров
//
// Возвращаемое значение:
//   Строка   – Строка описания настроек, выводимая в шапку отчета
//
Функция ПолучитьОписаниеНастроек()
	
	СтрокаСубконто = "";
	СтрокаКорСубконто = "";
	
	Для каждого стр Из ВидыСубконто Цикл
		СтрокаСубконто = СтрокаСубконто + ", " + Строка(стр.ВидСубконто);
	КонецЦикла;
	
	Для каждого стр Из КорВидыСубконто Цикл
		СтрокаКорСубконто = СтрокаКорСубконто + ", " + Строка(стр.ВидСубконто);
	КонецЦикла;
	
	СтрокаОписания = "Анализируется " + Сред(СтрокаСубконто, 3) + " в корреспонденции с " + Сред(СтрокаКорСубконто, 3);
	
	Возврат СтрокаОписания;
	
КонецФункции // ПолучитьОписаниеНастроек()

// Выводит заголовок отчета
//
// Параметры:
//	Нет.
//
Функция СформироватьЗаголовок() Экспорт

	ОписаниеПериода = БухгалтерскиеОтчеты.СформироватьСтрокуВыводаПараметровПоДатам(ДатаНач, ДатаКон);
	
	Макет = ПолучитьМакет("Макет");
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьЗаголовок=Макет.Область("Заголовок");
	
	// После удаления областей нужно установить свойства ПоВыделеннымКолонкам
	Для Сч = 1 По ЗаголовокОтчета.ВысотаТаблицы-1 Цикл
		
		Макет.Область(ОбластьЗаголовок.Верх+Сч, 2, ОбластьЗаголовок.Верх+Сч, 2).РазмещениеТекста = ТипРазмещенияТекстаТабличногоДокумента.Переносить;
		Макет.Область(ОбластьЗаголовок.Верх+Сч, 2, ОбластьЗаголовок.Верх+Сч, ОбластьЗаголовок.Право).ПоВыделеннымКолонкам = Истина;
		
	КонецЦикла;
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");

	НазваниеОрганизации = Организация.НаименованиеПолное;
	Если ПустаяСтрока(НазваниеОрганизации) Тогда
		НазваниеОрганизации = Организация;
	КонецЕсли;
	
	ОписаниеНастроек = ПолучитьОписаниеНастроек();
	
	ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ЗаголовокОтчета.Параметры.ОписаниеПериода     = ОписаниеПериода;
	ЗаголовокОтчета.Параметры.ОписаниеНастроек    = ОписаниеНастроек;
	ЗаголовокОтчета.Параметры.Заголовок           = ЗаголовокОтчета();
	
	// Вывод списка группировок:
	Если ПостроительОтчета.ИзмеренияСтроки.Количество() > 0 Тогда
		ЗаголовокОтчета.Параметры.ТекстПроГруппировки = "Группировки: " + УправлениеОтчетами.СформироватьСтрокуИзмерений(ПостроительОтчета.ИзмеренияСтроки);
	КонецЕсли;
	
	// Вывод отборов:
	СтрОтбор = УправлениеОтчетами.СформироватьСтрокуОтборов(ПостроительОтчета.Отбор);
	
	Если Не ПустаяСтрока(СтрОтбор) Тогда
		ОбластьОтбор = Макет.ПолучитьОбласть("СтрокаОтбор");
		ОбластьОтбор.Параметры.ТекстПроОтбор = "Отбор: " + СтрОтбор;
		ЗаголовокОтчета.Вывести(ОбластьОтбор);
	КонецЕсли;

	Возврат(ЗаголовокОтчета);

КонецФункции // СформироватьЗаголовок()


//////////////////////////////////////////////////////////
// СОХРАНЕНИЕ И ВОССТАНОВЛЕНИЕ ПАРАМЕТРОВ ОТЧЕТА
//

Функция СформироватьСтруктуруДляСохраненияНастроек() Экспорт

	СтруктураНастроек = Новый Структура;
	
	СтруктураНастроек.Вставить("Организация", Организация);
	
	СтруктураНастроек.Вставить("ДатаНач"    , ДатаНач);
	СтруктураНастроек.Вставить("ДатаКон"    , Макс(ДатаНач, ДатаКон));
	
	СтруктураНастроек.Вставить("НастройкиПостроителя", ПостроительОтчета.ПолучитьНастройки());
	
	Для каждого стр Из ВидыСубконто Цикл
		СтруктураНастроек.Вставить("ВидСубконто"+стр.НомерСтроки, стр.ВидСубконто);
	КонецЦикла;
	Для каждого стр Из КорВидыСубконто Цикл
		СтруктураНастроек.Вставить("КорВидСубконто"+стр.НомерСтроки, стр.ВидСубконто);
	КонецЦикла;
	
	Возврат СтруктураНастроек;

КонецФункции // СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок)

Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт

	Перем НастройкиПостроителя;
	
	Если ТипЗнч(СтруктураСНастройками) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("Организация", Организация);
	
	СтруктураСНастройками.Свойство("ДатаНач"    , ДатаНач);
	СтруктураСНастройками.Свойство("ДатаКон"    , ДатаКон);
	
	Для каждого Элемент Из СтруктураСНастройками Цикл
	
		Если Врег(Лев(Элемент.Ключ, 11)) = "ВИДСУБКОНТО" Тогда
		
			НомерСтроки = Число(Сред(Элемент.Ключ, 12));
			
			Пока ВидыСубконто.Количество()<НомерСтроки Цикл
				ВидыСубконто.Добавить();
			КонецЦикла;
			
			стр = ВидыСубконто.Получить(НомерСтроки-1);
			стр.ВидСубконто = Элемент.Значение;
		КонецЕсли;
	
	КонецЦикла;
	
	Для каждого Элемент Из СтруктураСНастройками Цикл
	
		Если Врег(Лев(Элемент.Ключ, 14)) = "КОРВИДСУБКОНТО" Тогда
		
			НомерСтроки = Число(Сред(Элемент.Ключ, 15));
			
			Пока КорВидыСубконто.Количество()<НомерСтроки Цикл
				КорВидыСубконто.Добавить();
			КонецЦикла;
			
			стр = КорВидыСубконто.Получить(НомерСтроки-1);
			стр.ВидСубконто = Элемент.Значение;
		КонецЕсли;
	
	КонецЦикла;

	ЗаполнитьНачальныеНастройки();
	
	СтруктураСНастройками.Свойство("НастройкиПостроителя", НастройкиПостроителя);
	Если ТипЗнч(НастройкиПостроителя) = Тип("НастройкиПостроителяОтчета") Тогда
		ПостроительОтчета.УстановитьНастройки(НастройкиПостроителя, Истина, Истина, Истина, Истина);
	КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////
// ПОСТРОЕНИЕ ОТЧЕТА
//

// Функция формирует текст запроса для построения отчета
//
// Параметры
//  Нет
//
// Возвращаемое значение:
//   Строка   – текст запроса для построения отчета
//
Функция ПолучитьТекстЗапроса()
    	
	ПоляВыбора = "";
	ПоляОтбора = "";
	ПоляОтбораСчет = "";
	ПоляОтбораКорСчет = "";
	ПоляИтогов = "";
	
	// получим список полей для выборки и для итогов
	Для каждого стр Из ПостроительОтчета.ИзмеренияСтроки Цикл
		
		ПоляВыбора = ПоляВыбора + ",
		|	Обороты." + стр.ПутьКДанным + " КАК " + стр.Имя;
		ПоляВыбора = ПоляВыбора + ",
		|	ПРЕДСТАВЛЕНИЕ(Обороты." + стр.ПутьКДанным + ") КАК " + стр.Имя+"Представление";
	
		ПоляИтогов = ПоляИтогов + ",
		|	" + стр.Имя + " " + БухгалтерскиеОтчеты.ПолучитьПоТипуИзмеренияПостроителяОтчетаСтрокуЗапроса(стр.ТипИзмерения);
		
	КонецЦикла;
	
	// получим текст отбора
	Сч = 0;
	Для каждого Элемент Из ПостроительОтчета.Отбор Цикл
		
		Если НЕ Элемент.Использование ИЛИ ПустаяСтрока(Элемент.ПутьКДанным) Тогда
			Продолжить;
		КонецЕсли;
		
		
		Если ВРег(Лев(Элемент.ПутьКДанным, 4)) = "СЧЕТ" Тогда
		
			ПоляОтбораСчет = ПоляОтбораСчет + " И " + УправлениеОтчетами.ПолучитьСтрокуОтбора(Элемент.ВидСравнения, "&ПараметрОтбора"+Сч, Элемент.ПутьКДанным, "&ПараметрОтбораС"+Сч, "&ПараметрОтбораПо"+Сч, Элемент.Значение, Элемент.ЗначениеС, Элемент.ЗначениеПо);
		
		ИначеЕсли ВРег(Лев(Элемент.ПутьКДанным, 7)) = "КОРСЧЕТ" Тогда
			
			ПоляОтбораКорСчет = ПоляОтбораКорСчет + " И " + УправлениеОтчетами.ПолучитьСтрокуОтбора(Элемент.ВидСравнения, "&ПараметрОтбора"+Сч, Элемент.ПутьКДанным, "&ПараметрОтбораС"+Сч, "&ПараметрОтбораПо"+Сч, Элемент.Значение, Элемент.ЗначениеС, Элемент.ЗначениеПо);
			
		Иначе
		
			ПоляОтбора = ПоляОтбора + " И " + УправлениеОтчетами.ПолучитьСтрокуОтбора(Элемент.ВидСравнения, "&ПараметрОтбора"+Сч, Элемент.ПутьКДанным, "&ПараметрОтбораС"+Сч, "&ПараметрОтбораПо"+Сч, Элемент.Значение, Элемент.ЗначениеС, Элемент.ЗначениеПо);
		
		КонецЕсли;
		
		Сч=Сч+1;
	
	КонецЦикла;
	
	ПоляОтбора    = Сред(ПоляОтбора, 4);
	ПоляОтбораСчет    = Сред(ПоляОтбораСчет, 4);
	ПоляОтбораКорСчет = Сред(ПоляОтбораКорСчет, 4);
	
	
	СтрокаОграниченийПоРеквизитам = "";
	БухгалтерскиеОтчеты.ДополнитьСтрокуОграниченийПоРеквизитам(СтрокаОграниченийПоРеквизитам, "Организация", Организация);
	Если Не ПустаяСтрока(ПоляОтбора)
		И Не ПустаяСтрока(СтрокаОграниченийПоРеквизитам) Тогда
		
		ПоляОтбора = " И " + ПоляОтбора;
		
	КонецЕсли;
	
	Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Обороты.Счет КАК Счет,
	|	Обороты.Счет.ВидыСубконто КАК СчетВидыСубконто,
	|	Обороты.КорСчет КАК КорСчет,
	|	Обороты.КорСчет.ВидыСубконто КАК КорСчетВидыСубконто,
	|	Обороты.Счет.Представление КАК СчетПредставление,
	|	Обороты.КорСчет.Представление КАК КорСчетПредставление,
	|	Обороты.Валюта КАК Валюта,
	|	Обороты.Валюта.Представление КАК ВалютаПредставление,
	|	Обороты.СуммаОборотДт КАК СуммаОборотДт,
	|	Обороты.СуммаОборотКт КАК СуммаОборотКт,
	|	Обороты.ВалютнаяСуммаОборотДт КАК ВалютнаяСуммаОборотДт,
	|	Обороты.ВалютнаяСуммаОборотКт КАК ВалютнаяСуммаОборотКт,
	|	Обороты.КоличествоОборотДт КАК КоличествоОборотДт,
	|	Обороты.КоличествоОборотКт КАК КоличествоОборотКт"
	+ ПоляВыбора + "
	|ИЗ
	|	РегистрБухгалтерии." + ИмяРегистраБухгалтерии + ".Обороты(&ДатаНач, &ДатаКон, Период, " + ПоляОтбораСчет + ", &МассивВидовСубконто, " + СтрокаОграниченийПоРеквизитам + ПоляОтбора + ", " + ПоляОтбораКорСчет + ", &МассивКорВидовСубконто) КАК Обороты
	|ИТОГИ
	|	СУММА(СуммаОборотДт),
	|	СУММА(СуммаОборотКт),
	|	СУММА(КоличествоОборотДт),
	|	СУММА(КоличествоОборотКт)
	|ПО
	|	ОБЩИЕ" + ПоляИтогов;
	
	Возврат Текст;

КонецФункции // ПолучитьТекстЗапроса()

Процедура УстановитьПараметрыЗапроса(Запрос)
	
	МассивВидовСубконто    = ВидыСубконто.ВыгрузитьКолонку("ВидСубконто");
	МассивКорВидовСубконто = КорВидыСубконто.ВыгрузитьКолонку("ВидСубконто");
	
	ОбщегоНазначения.УдалитьНеЗаполненныеЭлементыМассива(МассивВидовСубконто);
	ОбщегоНазначения.УдалитьНеЗаполненныеЭлементыМассива(МассивКорВидовСубконто);
	
	Запрос.УстановитьПараметр("Организация", Организация);
	
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	Если ДатаКон <> '00010101000000' Тогда
		Запрос.УстановитьПараметр("ДатаКон", КонецДня(ДатаКон));
	Иначе
		Запрос.УстановитьПараметр("ДатаКон", ДатаКон);
	КонецЕсли;
		
	Запрос.УстановитьПараметр("МассивВидовСубконто",    МассивВидовСубконто);
	Запрос.УстановитьПараметр("МассивКорВидовСубконто", МассивКорВидовСубконто);
	
	Сч = 0;
	Для каждого Элемент Из ПостроительОтчета.Отбор Цикл
		
		Если НЕ Элемент.Использование ИЛИ ПустаяСтрока(Элемент.ПутьКДанным) Тогда
			Продолжить;
		КонецЕсли;
		
		Запрос.УстановитьПараметр("ПараметрОтбора"+Сч,   Элемент.Значение);
		Запрос.УстановитьПараметр("ПараметрОтбораС"+Сч,  Элемент.ЗначениеС);
		Запрос.УстановитьПараметр("ПараметрОтбораПо"+Сч, Элемент.ЗначениеПо);
		
		Сч=Сч+1;
	
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьОбщуюРасшифровку(ДокументРезультат)

	СтруктураНастроекОтчета = Новый Структура;

	СтруктураНастроекОтчета.Вставить("ДатаНач", ДатаНач);
	СтруктураНастроекОтчета.Вставить("ДатаКон", ДатаКон);
	СтруктураНастроекОтчета.Вставить("Организация", Организация);
	
	НастройкиОтбора = УправлениеОтчетами.ПолучитьКопиюОтбораВТЗ(ПостроительОтчета.Отбор);
	
	СтруктураНастроекОтчета.Вставить("Отбор", НастройкиОтбора);

	
	
	ДокументРезультат.Область(1,1).Расшифровка = СтруктураНастроекОтчета;

КонецПроцедуры

// Получить расшифровку для отчета
//
// Параметры
//  ОтборДляРасшифровки  – Структура – отбор для расшифровки
//
// Возвращаемое значение:
//   СписокЗначений   – расшифровка
//
Функция ПолучитьРасшифровку(ОтборДляРасшифровки, БазоваяРасшифровка=Неопределено)
	
	СписокРасшифровки = Новый СписокЗначений;
	
	Если БазоваяРасшифровка <> Неопределено Тогда
		Расшифровка = БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(БазоваяРасшифровка);
	Иначе
		Расшифровка = Новый Структура;
	КонецЕсли;
	
	ОтборПоСубконто = Новый Соответствие;
	Для каждого Элемент Из ОтборДляРасшифровки Цикл
		
		ИмяКлюча = Врег(Элемент.Ключ);
		Измерение = ПостроительОтчета.ИзмеренияСтроки.Найти(Элемент.Ключ);
		
		Если Лев(ИмяКлюча, 8) = "СУБКОНТО" Тогда
			
			Если Не Расшифровка.Свойство("Счет") Тогда
				ОтборПоСубконто.Вставить(Измерение.ПутьКДанным, Элемент.Значение);
			Иначе
				Счет = Расшифровка.Счет;
				СчетВидыСубконто = Расшифровка.СчетВидыСубконто.Выгрузить();
				
				поз = Найти(Измерение.ПутьКДанным+".", ".");
				НомерСубконто = Число(Сред(Измерение.ПутьКДанным, 9, поз-9));
				
				СтрокаВидаСубконто = СчетВидыСубконто.Найти(ВидыСубконто[НомерСубконто-1].ВидСубконто, "ВидСубконто");
				НовыйНомерСубконто = СчетВидыСубконто.Индекс(СтрокаВидаСубконто) + 1;
				
				ИмяСубконто = "Субконто" + НовыйНомерСубконто + ?(поз=0, "", Сред(Измерение.ПутьКДанным, поз));
				
				ОтборПоСубконто.Вставить(ИмяСубконто, Элемент.Значение);
				
			КонецЕсли;
			
		ИначеЕсли Лев(ИмяКлюча, 11) = "КОРСУБКОНТО" Тогда
			
			Если Не Расшифровка.Свойство("КорСчет") Тогда
				ОтборПоСубконто.Вставить(Измерение.ПутьКДанным, Элемент.Значение);
			Иначе
				Счет = Расшифровка.КорСчет;
				СчетВидыСубконто = Расшифровка.КорСчетВидыСубконто.Выгрузить();
				
				поз = Найти(Измерение.ПутьКДанным+".", ".");
				НомерСубконто = Число(Сред(Измерение.ПутьКДанным, 12, поз-12));
				
				СтрокаВидаСубконто = СчетВидыСубконто.Найти(КорВидыСубконто[НомерСубконто-1].ВидСубконто, "ВидСубконто");
				НовыйНомерСубконто = СчетВидыСубконто.Индекс(СтрокаВидаСубконто) + 1;
				
				ИмяСубконто = "КорСубконто" + НовыйНомерСубконто + ?(поз=0, "", Сред(Измерение.ПутьКДанным, поз));
				
				ОтборПоСубконто.Вставить(ИмяСубконто, Элемент.Значение);
				
			КонецЕсли;
		Иначе
			
			ОтборПоСубконто.Вставить(Измерение.ПутьКДанным, Элемент.Значение);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Расшифровка.Вставить("Отбор", ОтборПоСубконто);
	
	Расшифровка.Вставить("ИмяОбъекта", "ОтчетПоПроводкам"+ИмяРегистраБухгалтерии);

	СписокРасшифровки.Добавить(Расшифровка, "Отчет по проводкам");
	
	Возврат СписокРасшифровки;
	
КонецФункции // ПолучитьРасшифровку()

Процедура ВывестиГруппировку(Выборка, НомерГруппировки, МассивГруппировок, ДокументРезультат, ОблСубконто, ОблДетали, ОтборДляРасшифровки)
	
	Если НомерГруппировки >= МассивГруппировок.Количество() Тогда
		
		// детальные записи
		ВыборкаДетали = Выборка.Выбрать(ОбходРезультатаЗапроса.Прямой);
		
		СтруктураДляРасшифровки = БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки);
		
		Пока ВыборкаДетали.Следующий() Цикл
			
			БазоваяРасшифровка = Новый Структура;
			
			БазоваяРасшифровка.Вставить("Счет", ВыборкаДетали.Счет);
			БазоваяРасшифровка.Вставить("КорСчет", ВыборкаДетали.КорСчет);
			БазоваяРасшифровка.Вставить("СчетВидыСубконто", ВыборкаДетали.СчетВидыСубконто);
			БазоваяРасшифровка.Вставить("КорСчетВидыСубконто", ВыборкаДетали.КорСчетВидыСубконто);
			
			ОблДетали.Параметры.Заполнить(ВыборкаДетали);
			ОблДетали.Параметры.ВалютаДт = ?(ЗначениеЗаполнено(ВыборкаДетали.ВалютнаяСуммаОборотДт), ВыборкаДетали.ВалютаПредставление, "");
			ОблДетали.Параметры.ВалютаКт = ?(ЗначениеЗаполнено(ВыборкаДетали.ВалютнаяСуммаОборотКт), ВыборкаДетали.ВалютаПредставление, "");
			
			ТекРасшифровка = ПолучитьРасшифровку(СтруктураДляРасшифровки, БазоваяРасшифровка);
			
			ДополнительныеОтборы = БухгалтерскиеОтчеты.СоздатьСтруктуруДопОграниченийДляОборотноСальдовойВедомостиПоСчету(ЭтотОбъект, ВыборкаДетали, МассивГруппировок, Истина);
			
			ТекРасшифровка[0].Значение.Вставить("ДополнительныеОтборы", ДополнительныеОтборы);
			
			ОблДетали.Параметры.Расшифровка = ТекРасшифровка;
						
			ДокументРезультат.Вывести(ОблДетали, НомерГруппировки - 1);
		
		КонецЦикла;
		
	Иначе
		// групповые записи
		ИмяГруппировки = МассивГруппировок[НомерГруппировки];
				
		ВыборкаСубконто = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, ИмяГруппировки);
				
		СтруктураДляРасшифровки = БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки);
		
		Пока ВыборкаСубконто.Следующий() Цикл
			
			СтруктураДляРасшифровки.Вставить(ВыборкаСубконто.Группировка(), ВыборкаСубконто[ВыборкаСубконто.Группировка()]);
			
			ОблСубконто.Параметры.ТекстСубконто = ВыборкаСубконто[ВыборкаСубконто.Группировка()+"Представление"];
			ОблСубконто.Параметры.Заполнить(ВыборкаСубконто);
			
			ТекРасшифровка = ПолучитьРасшифровку(СтруктураДляРасшифровки);
			
			ДополнительныеОтборы = БухгалтерскиеОтчеты.СоздатьСтруктуруДопОграниченийДляОборотноСальдовойВедомостиПоСчету(ЭтотОбъект, ВыборкаСубконто, МассивГруппировок);
				
			ТекРасшифровка[0].Значение.Вставить("ДополнительныеОтборы", ДополнительныеОтборы);
			
			ОблСубконто.Параметры.Расшифровка = ТекРасшифровка;
			
			ДокументРезультат.Вывести(ОблСубконто, НомерГруппировки - 1);
			
			ВывестиГруппировку(ВыборкаСубконто, НомерГруппировки + 1, МассивГруппировок, ДокументРезультат, ОблСубконто, ОблДетали, СтруктураДляРасшифровки);
			
		КонецЦикла;
	
	КонецЕсли;
	
КонецПроцедуры

Процедура ВывестиОтчет(ДокументРезультат, Макет)
	
	ОблШапка = Макет.ПолучитьОбласть("Шапка");
	ОблСубконто = Макет.ПолучитьОбласть("Субконто");
	ОблДетали = Макет.ПолучитьОбласть("Детали");
	
	ДокументРезультат.Вывести(ОблШапка, 0);
	
	Состояние("Выполнение запроса");
	
	Запрос = Новый Запрос(ПолучитьТекстЗапроса());
	
	УстановитьПараметрыЗапроса(Запрос);
	
	Результат = Запрос.Выполнить();
	
	МассивГруппировок = СформироватьМассивГруппировок();
	
	ВыборкаОбщие = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ОБЩИЕ");
	ВыборкаОбщие.Следующий();
	
	ДокументРезультат.НачатьАвтогруппировкуСтрок();
	
	ВывестиГруппировку(ВыборкаОбщие, 1, МассивГруппировок, ДокументРезультат, ОблСубконто, ОблДетали, Новый Структура);
	
	ДокументРезультат.ЗакончитьАвтогруппировкуСтрок();
	
КонецПроцедуры

//Функция возвращает массив группировок для отчета
Функция СформироватьМассивГруппировок() Экспорт
	
	МассивГруппировок = Новый Массив;
	
	МассивГруппировок.Добавить("ОБЩИЕ");
	
	Для Сч = 0 По ПостроительОтчета.ИзмеренияСтроки.Количество() - 1  Цикл
		
		МассивГруппировок.Добавить(ПостроительОтчета.ИзмеренияСтроки[Сч].Имя);
		
	КонецЦикла;

	Возврат МассивГруппировок;
		
КонецФункции

// Формирование отчета
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Истина, ВысотаЗаголовка = 0) Экспорт

	ОграничениеПоДатамКорректно = БухгалтерскиеОтчеты.ПроверитьКорректностьОграниченийПоДатам(ДатаНач, ДатаКон);
	Если НЕ ОграничениеПоДатамКорректно Тогда
        Возврат;
	КонецЕсли;

	Если ВидыСубконто.Количество()=0 Тогда
		Предупреждение("Не указаны анализируемые виды субконто", 60);
		Возврат;
	КонецЕсли;
	
	Если КорВидыСубконто.Количество()=0 Тогда
		Предупреждение("Не указаны анализируемые виды корреспондирующих субконто", 60);
		Возврат;
	КонецЕсли;
	
	ДокументРезультат.Очистить();

	Макет = ПолучитьМакет("Макет");

	БухгалтерскиеОтчеты.СформироватьИВывестиЗаголовокОтчета(ЭтотОбъект, ДокументРезультат, ВысотаЗаголовка, ПоказыватьЗаголовок);
	
	ЗаполнитьОбщуюРасшифровку(ДокументРезультат);
	
	/////////////////////////////////
	// здесь формируем отчет
	/////////////////////////////////
	ВывестиОтчет(ДокументРезультат, Макет);
	/////////////////////////////////
	
	// Зафиксируем заголовок отчета
	ДокументРезультат.ФиксацияСверху = ВысотаЗаголовка + 3;

	// Первую колонку не печатаем
	ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
	ДокументРезультат.ПовторятьПриПечатиСтроки = ДокументРезультат.Область(ВысотаЗаголовка+1,,ВысотаЗаголовка+3);
	
	// Присвоим имя для сохранения параметров печати табличного документа
	ДокументРезультат.ИмяПараметровПечати = "ШаблонСтандартногоОтчета "+ИмяРегистраБухгалтерии;

	УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(ДокументРезультат, ЗаголовокОтчета(), Строка(глЗначениеПеременной("глТекущийПользователь")));
	
КонецПроцедуры


//////////////////////////////////////////////////////////
// ПРОЧИЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Настраивает отчет по заданным параметрам (например, для расшифровки)
Процедура Настроить(СтруктураПараметров) Экспорт
	
	Параметры = БухгалтерскиеОтчеты.СоздатьПоСтруктуреСоответствие(СтруктураПараметров);

	Организация = Параметры["Организация"];
	ДатаНач = Параметры["ДатаНач"];
	ДатаКон = Параметры["ДатаКон"];
	
	ЗаполнитьНачальныеНастройки();
	ДобавитьОтборПоВалюте();
	
	СтрокиОтбора = Параметры["Отбор"];
	
	Если ТипЗнч(СтрокиОтбора) = Тип("Соответствие")
		ИЛИ ТипЗнч(СтрокиОтбора) = Тип("Структура") Тогда
	
		Для каждого ЭлементОтбора Из СтрокиОтбора Цикл
			
			Если ЭлементОтбора.Ключ = "Валюта" Тогда
				
				Валюта = ЭлементОтбора.Значение;
				ПоВалюте = ЗначениеЗаполнено(Валюта);
				
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

// Заполнение настроек построителя отчета
Процедура ЗаполнитьНачальныеНастройки() Экспорт

	ТекстОтбораСубконто = ", Валюта, ВалютаКор";
	ТекстОтбораКорСубконто = "";
	ТекстПолейСубконто = "";
	ТекстПолейКорСубконто = "";
	ТекстУпорядочитьСубконто = "";
	ТекстУпорядочитьКорСубконто = "";
	
	
	Для н=1 По ВидыСубконто.Количество() Цикл
		
		ТекстОтбораСубконто    = ТекстОтбораСубконто    + ", Субконто"   +н+".*";
		
		ТекстПолейСубконто    = ТекстПолейСубконто    + ", Обороты.Субконто"   +н+".* КАК Субконто"+н;
		
		ТекстУпорядочитьСубконто    = ТекстУпорядочитьСубконто    + ", Обороты.Субконто"   +н+".*";
		
	КонецЦикла;
	
	Для н=1 По КорВидыСубконто.Количество() Цикл
		
		ТекстОтбораКорСубконто = ТекстОтбораКорСубконто + ", КорСубконто"+н+".*";
		
		ТекстПолейКорСубконто = ТекстПолейКорСубконто + ", Обороты.КорСубконто"+н+".* КАК КорСубконто"+н;
		
		ТекстУпорядочитьКорСубконто = ТекстУпорядочитьКорСубконто + ", Обороты.КорСубконто"+н+".*";
		
	КонецЦикла;
	
	ТекстОтбора = ТекстОтбораСубконто + ТекстОтбораКорСубконто;
	ТекстПолей = ТекстПолейСубконто + ТекстПолейКорСубконто;
	ТекстУпорядочить = ТекстУпорядочитьСубконто + ТекстУпорядочитьКорСубконто;
	
	ТекстОтбора = Сред(ТекстОтбора, 3);
	ТекстПолей = Сред(ТекстПолей, 3);
	ТекстУпорядочить = Сред(ТекстУпорядочить, 3);
	
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Обороты.Счет КАК Счет,
	|	Обороты.КорСчет КАК КорСчет,
	|	Обороты.Валюта КАК Валюта,
	|	Обороты.СуммаОборотДт КАК СуммаОборотДт,
	|	Обороты.СуммаОборотКт КАК СуммаОборотКт,
	|	Обороты.ВалютнаяСуммаОборотДт КАК ВалютнаяСуммаОборотДт,
	|	Обороты.ВалютнаяСуммаОборотКт КАК ВалютнаяСуммаОборотКт,
	|	Обороты.КоличествоОборотДт КАК КоличествоОборотДт,
	|	Обороты.КоличествоОборотКт КАК КоличествоОборотКт
	|" + ?(Не ПустаяСтрока(ТекстПолей), "{ВЫБРАТЬ
	|	"+ТекстПолей+"}", "")+"
	|ИЗ
	|	РегистрБухгалтерии."+ИмяРегистраБухгалтерии+".Обороты(&ДатаНач, &ДатаКон, Период, {Счет.*}, &МассивВидовСубконто, Организация = &Организация " + ?(Не ПустаяСтрока(ТекстОтбора), "{"+ТекстОтбора+"}", "") + " , {КорСчет.*}, &МассивКорВидовСубконто) КАК Обороты
	|" + ?(Не ПустаяСтрока(ТекстУпорядочить), "{УПОРЯДОЧИТЬ ПО
	|	"+ТекстУпорядочить+"}","") + "
	|ИТОГИ СУММА(СуммаОборотДт), СУММА(СуммаОборотКт), СУММА(КоличествоОборотДт), СУММА(КоличествоОборотКт) ПО ОБЩИЕ
	|"+?(Не ПустаяСтрока(ТекстПолей), "{ИТОГИ ПО
	|	"+ТекстПолей+"}","") + "
	|АВТОУПОРЯДОЧИВАНИЕ";

	ПостроительОтчета.Параметры.Вставить("ДатаНач", ДатаНач);
	ПостроительОтчета.Параметры.Вставить("ДатаКон", ДатаКон);
	ПостроительОтчета.Параметры.Вставить("Организация", Организация);
	
	МассивВидовСубконто    = ВидыСубконто.ВыгрузитьКолонку("ВидСубконто");
	МассивКорВидовСубконто = КорВидыСубконто.ВыгрузитьКолонку("ВидСубконто");
	
	Колво = МассивВидовСубконто.Количество()-1;
	Для н=0 По Колво Цикл
		Если НЕ ЗначениеЗаполнено(МассивВидовСубконто[Колво-н]) Тогда
			МассивВидовСубконто.Удалить(Колво-н);
		КонецЕсли;
	КонецЦикла;
	
	Колво = МассивКорВидовСубконто.Количество()-1;
	Для н=0 По Колво Цикл
		Если НЕ ЗначениеЗаполнено(МассивКорВидовСубконто[Колво-н]) Тогда
			МассивКорВидовСубконто.Удалить(Колво-н);
		КонецЕсли;
	КонецЦикла;
	
	ПостроительОтчета.Параметры.Вставить("МассивВидовСубконто", МассивВидовСубконто);
	ПостроительОтчета.Параметры.Вставить("МассивКорВидовСубконто", МассивКорВидовСубконто);
	
	ПостроительОтчета.Текст = ТекстЗапроса;
	
	Сч = 0;
	Для каждого Элемент Из МассивВидовСубконто Цикл
		Сч = Сч+1;
		Поле = ПостроительОтчета.ДоступныеПоля.Найти("Субконто"+Сч);
		Поле.ТипЗначения = Элемент.ТипЗначения;
		Поле.Представление = Элемент.Наименование;
	КонецЦикла;
	
	Сч = 0;
	Для каждого Элемент Из МассивКорВидовСубконто Цикл
		Сч = Сч+1;
		Поле = ПостроительОтчета.ДоступныеПоля.Найти("КорСубконто"+Сч);
		Поле.ТипЗначения = Элемент.ТипЗначения;
		Поле.Представление = "Кор "+Элемент.Наименование;
	КонецЦикла;
	
	Поле = ПостроительОтчета.ДоступныеПоля.Найти("ВалютаКор");
	Поле.Представление = "Кор Валюта";
	
КонецПроцедуры

Процедура ПерезаполнитьНачальныеНастройки() Экспорт
	
	Настройки = ПостроительОтчета.ПолучитьНастройки();
	
	ЗаполнитьНачальныеНастройки();
	
	ПостроительОтчета.УстановитьНастройки(Настройки);
	
	ДобавитьОтборПоВалюте();
	
КонецПроцедуры

// Обработчик события начала выбора значения субконто
//
// Параметры:
//	Элемент управления.
//	Стандартная обработка.
//
Процедура НачалоВыбораЗначенияСубконто(Элемент, СтандартнаяОбработка, ТипЗначенияПоля=Неопределено) Экспорт
	
	СписокПараметров = Новый Структура;
	СписокПараметров.Вставить("Дата",         ДатаКон);
	СписокПараметров.Вставить("СчетУчета",    Неопределено);
	СписокПараметров.Вставить("Номенклатура", Неопределено);
	СписокПараметров.Вставить("Склад", Неопределено);
	СписокПараметров.Вставить("Организация",  Организация);
	СписокПараметров.Вставить("Контрагент",  Неопределено);
	СписокПараметров.Вставить("ДоговорКонтрагента", Неопределено);
	СписокПараметров.Вставить("ЭтоНовыйДокумент", Ложь);
	
	// Поищем значения в отборе и в полях выбора субконто
	Для Инд=0 По ПостроительОтчета.Отбор.Количество()-1 Цикл
		
		СтрокаОтбора = ПостроительОтчета.Отбор[Инд];
		
		ЗначениеОтбора=?(ТипЗнч(СтрокаОтбора.Значение)<> Тип("СписокЗначений"), СтрокаОтбора.Значение, СтрокаОтбора.Значение[0].Значение);
		
		Если СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура.ТипЗначения Тогда
			СписокПараметров.Вставить("Номенклатура", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады.ТипЗначения Тогда
			СписокПараметров.Вставить("Склад", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты.ТипЗначения Тогда
			СписокПараметров.Вставить("Контрагент", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры.ТипЗначения Тогда
			СписокПараметров.Вставить("ДоговорКонтрагента", ЗначениеОтбора);
		КонецЕсли;
		
	КонецЦикла;
	
	БухгалтерскийУчет.ОбработатьВыборСубконто(Элемент, СтандартнаяОбработка, Организация, СписокПараметров, ТипЗначенияПоля);
	
КонецПроцедуры // ОбработкаВыбораСубконто()

// Если в настройке отбора нет поля валюты, его надо добавить
//
// Параметры
//    Нет
//
Процедура ДобавитьОтборПоВалюте()

	Поле = Неопределено;
	
	Для каждого ПолеОтбора Из ПостроительОтчета.Отбор Цикл
	
		Если Врег(ПолеОтбора.ПутьКДанным) = Врег("Валюта") Тогда
			Поле = ПолеОтбора;
			Прервать;
		КонецЕсли;
	
	КонецЦикла;
	
	Если Поле = Неопределено Тогда
	
		Поле = ПостроительОтчета.Отбор.Добавить("Валюта");
		Поле.Использование = Ложь;
	
	КонецЕсли;

	Поле = Неопределено;
	
	Для каждого ПолеОтбора Из ПостроительОтчета.Отбор Цикл
	
		Если Врег(ПолеОтбора.ПутьКДанным) = Врег("ВалютаКор") Тогда
			Поле = ПолеОтбора;
			Прервать;
		КонецЕсли;
	
	КонецЦикла;
	
	Если Поле = Неопределено Тогда
	
		Поле = ПостроительОтчета.Отбор.Добавить("ВалютаКор");
		Поле.Использование = Ложь;
	
	КонецЕсли;
	
КонецПроцедуры // ДобавитьОтборПоВалюте()

//////////////////////////////////////////////////////////
// МОДУЛЬ ОБЪЕКТА
//

ИмяРегистраБухгалтерии = "Налоговый";

ИмяПланаСчетов = Метаданные.РегистрыБухгалтерии[ИмяРегистраБухгалтерии].ПланСчетов.Имя;

МаксКоличествоСубконто = Метаданные.ПланыСчетов[ИмяПланаСчетов].МаксКоличествоСубконто;

#КонецЕсли