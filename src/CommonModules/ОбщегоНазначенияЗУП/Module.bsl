
// Процедура предназначена для заполнения общих реквизитов документов,
// вызывается в обработчиках событий "ПриОткрытии" в модулех форм всех документов.
//
// Параметры:
//  ДокументОбъект                 - объект редактируемого документа,
//  ТекПользователь                - ссылка на справочник, определяет текущего пользователя  
//  ВалютаРегламентированногоУчета - валюта регламентированного учета
//  ТипОперации                    - необязаетельный, строка вида операции ("Покупка" или "Продажа"),
//                                   если не передан, то реквизиты, зависящие от вида операции, не заполняются
//
Процедура ЗаполнитьШапкуДокумента(ДокументОбъект, ТекПользователь, ВалютаРегламентированногоУчета = Неопределено, ТипОперации = "") Экспорт

	МетаданныеДокумента = ДокументОбъект.Метаданные();

	Если МетаданныеДокумента.Реквизиты.Найти("Ответственный") <> Неопределено Тогда
		ДокументОбъект.Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновнойОтветственный");
	КонецЕсли;

	// Флаги принадлежности к учету заполняем, только если оба не заполнены
	Если МетаданныеДокумента.Реквизиты.Найти("ОтражатьВУправленческомУчете") <> Неопределено
		И МетаданныеДокумента.Реквизиты.Найти("ОтражатьВБухгалтерскомУчете") <> Неопределено Тогда
		Если Не (ДокументОбъект.ОтражатьВУправленческомУчете 
			или ДокументОбъект.ОтражатьВБухгалтерскомУчете) Тогда

			ДокументОбъект.ОтражатьВУправленческомУчете = Ложь;
			ДокументОбъект.ОтражатьВБухгалтерскомУчете  = Истина;


		КонецЕсли;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("Подразделение") <> Неопределено 
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.Подразделение)) Тогда
		ДокументОбъект.Подразделение = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновноеПодразделение");
	КонецЕсли;
	
	ПроверятьСоответствиеПодразделенияОрганизации = Ложь;
	Если МетаданныеДокумента.Реквизиты.Найти("Организация") <> Неопределено Тогда
		ПроверятьСоответствиеПодразделенияОрганизации = Истина;
		Если (НЕ ЗначениеЗаполнено(ДокументОбъект.Организация)) Тогда
			ДокументОбъект.Организация = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновнаяОрганизация");
		КонецЕсли;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("ВидОперации") <> Неопределено
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВидОперации)) Тогда
		ДокументОбъект.ВидОперации = Перечисления[ДокументОбъект.ВидОперации.Метаданные().Имя][0];
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("СчетОрганизации") <> Неопределено
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.СчетОрганизации))
		И (ЗначениеЗаполнено(ДокументОбъект.Организация.ЮрФизЛицо)) Тогда
		СчетПоУмолчанию = ДокументОбъект.Организация.ОсновнойБанковскийСчет;
		ДокументОбъект.СчетОрганизации = СчетПоУмолчанию;
		Если МетаданныеДокумента.Реквизиты.Найти("ВалютаДокумента") <> Неопределено
			И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВалютаДокумента)) Тогда
			ДокументОбъект.ВалютаДокумента =  СчетПоУмолчанию.ВалютаДенежныхСредств;
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("ПодразделениеОрганизации") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ПодразделениеОрганизации)) Тогда
	   ПодразделениеПоУмолчанию = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновноеПодразделениеОрганизации");;
	   Если ПроверятьСоответствиеПодразделенияОрганизации Тогда
		   Если ПодразделениеПоУмолчанию.Владелец = ДокументОбъект.Организация Тогда
			   ДокументОбъект.ПодразделениеОрганизации = ПодразделениеПоУмолчанию;
		   КонецЕсли;
	   Иначе 	
		   ДокументОбъект.ПодразделениеОрганизации = ПодразделениеПоУмолчанию;
	   КонецЕсли;
	КонецЕсли;
		
	Если МетаданныеДокумента.Реквизиты.Найти("ВалютаДокумента") <> Неопределено
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВалютаДокумента)) Тогда
		ДокументОбъект.ВалютаДокумента = ВалютаРегламентированногоУчета;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("КурсДокумента") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.КурсДокумента)) Тогда
		СтруктураКурсаДокумента      = МодульВалютногоУчета.ПолучитьКурсВалюты(ДокументОбъект.ВалютаДокумента, ДокументОбъект.Дата);
		ДокументОбъект.КурсДокумента = СтруктураКурсаДокумента.Курс;

		Если МетаданныеДокумента.Реквизиты.Найти("КратностьДокумента") <> Неопределено Тогда
			ДокументОбъект.КратностьДокумента = СтруктураКурсаДокумента.Кратность;
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("ДатаОплаты") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ДатаОплаты)) Тогда
		ДокументОбъект.ДатаОплаты = ДокументОбъект.Дата;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("ЗанимаемыхСтавок") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ЗанимаемыхСтавок)) Тогда
		ДокументОбъект.ЗанимаемыхСтавок = 1;
	КонецЕсли;
	

	Если МетаданныеДокумента.Реквизиты.Найти("ПериодРегистрации") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ПериодРегистрации)) Тогда
		ДокументОбъект.ПериодРегистрации = НачалоМесяца(ОбщегоНазначения.ПолучитьРабочуюДату());
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьШапкуДокумента()

// Процедура предназначена для заполнения общих реквизитов документов по документу основанию,
//	вызывается в обработчиках событий "ОбработкаЗаполнения" в модулях документов.
//
// Параметры:
//  ДокументОбъект  - объект редактируемого документа,
//  ДокументОснование - объект документа основания
//
Процедура ЗаполнитьШапкуДокументаПоОснованию(ДокументОбъект, ДокументОснование) Экспорт

	МетаданныеДокумента          = ДокументОбъект.Метаданные();
	МетаданныеДокументаОснования = ДокументОснование.Метаданные();

	// Организация.
	Если МетаданныеДокумента.Реквизиты.Найти("Организация") <> Неопределено
		И МетаданныеДокументаОснования.Реквизиты.Найти("Организация") <> Неопределено Тогда
		ДокументОбъект.Организация = ДокументОснование.Организация;
	КонецЕсли;

	// Подразделение.
	Если МетаданныеДокумента.Реквизиты.Найти("Подразделение") <> Неопределено
	   И МетаданныеДокументаОснования.Реквизиты.Найти("Подразделение") <> Неопределено Тогда
		ДокументОбъект.Подразделение = ДокументОснование.Подразделение;
	КонецЕсли;

	// Подразделение.
	Если МетаданныеДокумента.Реквизиты.Найти("ПодразделениеОрганизации") <> Неопределено
	   И МетаданныеДокументаОснования.Реквизиты.Найти("ПодразделениеОрганизации") <> Неопределено Тогда
		ДокументОбъект.ПодразделениеОрганизации = ДокументОснование.ПодразделениеОрганизации;
	КонецЕсли;

	// Банковский счет 
	Если МетаданныеДокумента.Реквизиты.Найти("БанковскийСчет") <> Неопределено
		И МетаданныеДокументаОснования.Реквизиты.Найти("БанковскийСчет") <> Неопределено Тогда
		
			Если ЗначениеЗаполнено(ДокументОснование.БанковскийСчет) Тогда
				ДокументОбъект.БанковскийСчет = ДокументОснование.БанковскийСчет;
			КонецЕсли;

	КонецЕсли;

	// ВалютаДокумента.
	Если МетаданныеДокумента.Реквизиты.Найти("ВалютаДокумента") <> Неопределено
	   И МетаданныеДокументаОснования.Реквизиты.Найти("ВалютаДокумента") <> Неопределено Тогда

		// Если есть банковский счет, то валюта должна браться только оттуда
		Если МетаданныеДокумента.Реквизиты.Найти("БанковскийСчет") <> Неопределено Тогда
			Если ЗначениеЗаполнено(ДокументОбъект.БанковскийСчет) Тогда
				ДокументОбъект.ВалютаДокумента = ДокументОбъект.БанковскийСчет.ВалютаДенежныхСредств;
			КонецЕсли;
		Иначе
			ДокументОбъект.ВалютаДокумента = ДокументОснование.ВалютаДокумента;
		КонецЕсли;

		// КурсДокумента.
		Если МетаданныеДокумента.Реквизиты.Найти("КурсДокумента") <> Неопределено Тогда
			СтруктураКурсаДокумента = МодульВалютногоУчета.ПолучитьКурсВалюты(ДокументОбъект.ВалютаДокумента, ТекущаяДата());
			ДокументОбъект.КурсДокумента = СтруктураКурсаДокумента.Курс;

			// КратностьДокумента.
			Если МетаданныеДокумента.Реквизиты.Найти("КратностьДокумента") <> Неопределено Тогда
				ДокументОбъект.КратностьДокумента = СтруктураКурсаДокумента.Кратность;
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;

	// ОтражатьВУправленческомУчете.
	// Если есть в основании, копируем из основания, иначе - Истина.
	Если МетаданныеДокумента.Реквизиты.Найти("ОтражатьВУправленческомУчете") <> Неопределено Тогда
		Если МетаданныеДокументаОснования.Реквизиты.Найти("ОтражатьВУправленческомУчете") <> Неопределено Тогда
			ДокументОбъект.ОтражатьВУправленческомУчете = ДокументОснование.ОтражатьВУправленческомУчете;
		Иначе
			ДокументОбъект.ОтражатьВУправленческомУчете = Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("ОтражатьВБухгалтерскомУчете") <> Неопределено Тогда
		Если МетаданныеДокументаОснования.Реквизиты.Найти("ОтражатьВБухгалтерскомУчете") <> Неопределено Тогда
			ДокументОбъект.ОтражатьВБухгалтерскомУчете = ДокументОснование.ОтражатьВБухгалтерскомУчете;
		Иначе
			ДокументОбъект.ОтражатьВБухгалтерскомУчете = Истина;
		КонецЕсли;
	КонецЕсли;
	

КонецПроцедуры // ЗаполнитьШапкуДокументаПоОснованию()


// Функция выполняет пропорциональное распределение суммы в соответствии
// с заданными коэффициентами распределения
//
// Параметры:
//		ИсхСумма - распределяемая сумма
//		МассивКоэф - массив коэффициентов распределения
//		Точность - точность округления при распределении. Необязателен.
//
//	Возврат:
//		МассивСумм - массив размерностью равный массиву коэффициентов, содержит
//			суммы в соответствии с весом коэффициента (из массива коэффициентов)
//          В случае если распределить не удалось (сумма = 0, кол-во коэф. = 0,
//          или суммарный вес коэф. = 0), тогда возвращается значение Неопределено
//
Функция РаспределитьПропорционально(Знач ИсхСумма, МассивКоэф, Знач Точность = 2) Экспорт
	
	Если МассивКоэф = Неопределено Или МассивКоэф.Количество() = 0 Или ИсхСумма = 0 Или ИсхСумма = Null Тогда	
		Возврат Неопределено;
	КонецЕсли;
	
	ИндексМакс = 0;
	МаксЗнач   = 0;
	РаспрСумма = 0;
	СуммаКоэф  = 0;
	
	Для К = 0 По МассивКоэф.Количество() - 1 Цикл
		
		МодульЧисла = ?(МассивКоэф[К] > 0, МассивКоэф[К], - МассивКоэф[К]);
		
		Если МаксЗнач < МодульЧисла Тогда
			МаксЗнач = МодульЧисла;
			ИндексМакс = К;
		КонецЕсли;
		
		СуммаКоэф = СуммаКоэф + МассивКоэф[К];
		
	КонецЦикла;
	
	Если СуммаКоэф = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МассивСумм = Новый Массив(МассивКоэф.Количество());
	
	Для К = 0 По МассивКоэф.Количество() - 1 Цикл
		МассивСумм[К] = Окр(ИсхСумма * МассивКоэф[К] / СуммаКоэф, Точность, 1);
		РаспрСумма = РаспрСумма + МассивСумм[К];
	КонецЦикла;
	
	// Погрешности округления отнесем на коэффициент с максимальным весом
	Если Не РаспрСумма = ИсхСумма Тогда
		МассивСумм[ИндексМакс] = МассивСумм[ИндексМакс] + ИсхСумма - РаспрСумма;
	КонецЕсли;
	
	Возврат МассивСумм;
	
КонецФункции // РаспределитьПропорционально()

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ ЗАПОЛНЕНИЯ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ

// Функция инициализирует глобальную переменную глУчетнаяПолитикаПоПерсоналу.
// Переменная содержит структуру.
//
// Параметры:
//  Нет.
//
Функция ЗаполнениеУчетнойПолитикиПоПерсоналу() Экспорт
	
	УчетнаяПолитикаПоПерсоналу = Новый Структура("РасчетЗарплатыПоОтветственным,ПоказыватьТабельныеНомераВДокументах,ПоддерживатьНесколькоСхемМотивации", Ложь, Ложь, Ложь);
	
	Выборка = РегистрыСведений.УчетнаяПолитикаПоПерсоналу.Выбрать();
	Пока Выборка.Следующий() Цикл
		УчетнаяПолитикаПоПерсоналу = Новый Структура("РасчетЗарплатыПоОтветственным,ПоказыватьТабельныеНомераВДокументах,ПоддерживатьНесколькоСхемМотивации", Выборка.РасчетЗарплатыПоОтветственным, Выборка.ПоказыватьТабельныеНомераВДокументах, Выборка.ПоддерживатьНесколькоСхемМотивации);
	КонецЦикла;
    
    Возврат УчетнаяПолитикаПоПерсоналу;	
КонецФункции

// Процедура инициализирует глобальную переменную глУчетнаяПолитикаПоПерсоналуОрганизации.
// Переменная содержит соответствие, где организация является ключом, а поддержка 
// поддержка внутреннего совместительства значением.
//
// Параметры:
//  Нет.
//
Функция ЗаполнениеУчетнойПолитикиПоПерсоналуОрганизации() Экспорт
	
	УчетнаяПолитикаПоПерсоналуОрганизации = Новый Соответствие;
	
	Если ПравоДоступа("Чтение", Метаданные.Справочники.Организации) Тогда
	
		Запрос = Новый Запрос(
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Организации.Ссылка КАК Организация,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.ПоддержкаВнутреннегоСовместительства, ЛОЖЬ) КАК ПоддержкаВнутреннегоСовместительства,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.ЕдиныйНумераторКадровыхДокументов, ЛОЖЬ) КАК ЕдиныйНумераторКадровыхДокументов,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.ПроверкаШтатногоРасписания, ЛОЖЬ) КАК ПроверкаШтатногоРасписания,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.РасчетЗарплатыОрганизацииПоОтветственным, ЛОЖЬ) КАК РасчетЗарплатыОрганизацииПоОтветственным,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.ИспользуютсяНачисленияВВалюте, ЛОЖЬ) КАК ИспользуютсяНачисленияВВалюте,
		|	ЕСТЬNULL(УчетнаяПолитикаПоПерсоналуОрганизаций.ПоказыватьТабельныеНомераВДокументах, ЛОЖЬ) КАК ПоказыватьТабельныеНомераВДокументах		
		|ИЗ		
		|	Справочник.Организации КАК Организации		
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.УчетнаяПолитикаПоПерсоналуОрганизаций КАК УчетнаяПолитикаПоПерсоналуОрганизаций		
		|		ПО (ВЫБОР		
		|				КОГДА Организации.ГоловнаяОрганизация = ЗНАЧЕНИЕ(Справочник.Организации.ПустаяСсылка)		
		|					ТОГДА Организации.Ссылка		
		|				ИНАЧЕ Организации.ГоловнаяОрганизация		
		|			КОНЕЦ = УчетнаяПолитикаПоПерсоналуОрганизаций.Организация)");
		
		УчетнаяПолитикаПоПерсоналуОрганизации.Вставить(Справочники.Организации.ПустаяСсылка(), 
			Новый Структура(
			"ПоддержкаВнутреннегоСовместительства,
			|ЕдиныйНумераторКадровыхДокументов,
			|ПроверкаШтатногоРасписания,
			|РасчетЗарплатыОрганизацииПоОтветственным,
			|ИспользуютсяНачисленияВВалюте,
			|ПоказыватьТабельныеНомераВДокументах",
			Ложь,
			Ложь,
			Ложь,
			Ложь,
			Ложь,
			Ложь));
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			УчетнаяПолитикаПоПерсоналуОрганизации.Вставить(Выборка.Организация, 
				Новый Структура(
				"ПоддержкаВнутреннегоСовместительства,
				|ЕдиныйНумераторКадровыхДокументов,
				|ПроверкаШтатногоРасписания,
				|РасчетЗарплатыОрганизацииПоОтветственным,
				|ИспользуютсяНачисленияВВалюте,				
				|ПоказыватьТабельныеНомераВДокументах",
				Выборка.ПоддержкаВнутреннегоСовместительства,
				Выборка.ЕдиныйНумераторКадровыхДокументов,
				Выборка.ПроверкаШтатногоРасписания,
				Выборка.РасчетЗарплатыОрганизацииПоОтветственным,
				Выборка.ИспользуютсяНачисленияВВалюте,
				Выборка.ПоказыватьТабельныеНомераВДокументах));
		КонецЦикла;
	
	КонецЕсли;
    
	Возврат УчетнаяПолитикаПоПерсоналуОрганизации;
	
КонецФункции // ЗаполнениеУчетнойПолитикиПоПерсоналуОрганизации

