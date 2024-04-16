Перем мПараметрыСвязиСтрокТЧ Экспорт;

Перем ИзмененоИспользоватьВидНорматива Экспорт;
Перем ИзмененоИспользоватьВидВоспроизводства Экспорт;
Перем ИзмененоИспользоватьУказаниеНорматива Экспорт;
Перем ИзмененоИспользоватьФормулы Экспорт;
Перем ИзмененоИспользоватьУправлениеСписанием Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
	
// Функция формирует табличный документ с печатной формой спецификации
// по ГОСТ 2.106-96.
//
// Возвращаемое значение:
//  Табличный документ - печатная форма спецификации
//
Функция ПечатьСпецификацииГост()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СпецификацииНоменклатуры.Ссылка.Код 		 			КАК Код,
	|	СпецификацииНоменклатуры.Ссылка.Наименование 			КАК Обозначение,
	|	ВЫРАЗИТЬ(СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Наименование,
	|	СпецификацииНоменклатуры.ХарактеристикаНоменклатуры 	КАК Характеристика,
	|	NULL 													КАК Серия
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.ВыходныеИзделия КАК СпецификацииНоменклатуры
	|ГДЕ
	|	СпецификацииНоменклатуры.Ссылка = &ТекущийЭлемент
	|";
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	
	МассивВидыНормативов = Новый Массив;
	МассивВидыНормативов.Добавить(Перечисления.ВидыНормативовНоменклатуры.Номенклатура);
	МассивВидыНормативов.Добавить(Перечисления.ВидыНормативовНоменклатуры.Узел);
	Запрос.УстановитьПараметр("ВидыНормативов", МассивВидыНормативов);
	
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	ПозицияПоСпецификации			КАК Позиция,
	|	Номенклатура,
	|	ХарактеристикаНоменклатуры 		КАК Характеристика,
	|	NULL							КАК Серия,
	|	Номенклатура.ВидНоменклатуры.Представление	КАК ВидНоменклатуры,
	|	ВЫБОР КОГДА Номенклатура.НаименованиеПолное ЕСТЬ NULL ТОГДА
	|		Номенклатура.Наименование
	|	ИНАЧЕ
	|		ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК Строка(1000))
	|	КОНЕЦ КАК Наименование,
	|	Номенклатура.Код     			КАК Обозначение,
	|	Количество						КАК Количество,
	|	ЕдиницаИзмерения.Представление 	КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.ИсходныеКомплектующие КАК СпецификацияНоменклатуры
	|ГДЕ
	|	СпецификацияНоменклатуры.Ссылка = &ТекущийЭлемент
	|	И СпецификацияНоменклатуры.ВидНорматива В (&ВидыНормативов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|	
	|ВЫБРАТЬ
	|	НомерСтроки КАК Позиция,
	|	Наименование КАК Номенклатура,
	|	Неопределено КАК Характеристика,
	|	Неопределено КАК Серия,
	|	""Документация"" КАК ВидНоменклатуры,
	|	Наименование,
	|	Обозначение,
	|	0 КАК Количество,
	|	Неопределено КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.Документация КАК Документация
	|ГДЕ
	|	Документация.Ссылка = &ТекущийЭлемент
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидНоменклатуры, 
	|	Позиция
	|	
	|";

	ЗапросМатериалы = Запрос.Выполнить().Выгрузить();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_СпецификацияГост";
	
	// Зададим параметры макета.
	ТабДокумент.ОбластьПечати = ТабДокумент.Область(2,2,ТабДокумент.ВысотаТаблицы, 8);
	ТабДокумент.ПолеСверху              = 5;
	ТабДокумент.ПолеСлева               = 15;
	ТабДокумент.ПолеСнизу               = 0;
	ТабДокумент.ПолеСправа              = 0;
	ТабДокумент.РазмерКолонтитулаСверху = 0;
	ТабДокумент.РазмерКолонтитулаСнизу  = 0;
	ТабДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Портрет;

	Макет = ПолучитьМакет("СпецификацияГост");

	НомерСтраницы = 1;
	
	// Выводим шапку спецификации.
	ЗаголовокТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ЗаголовокТаблицы);
	
	ОбластьОсновнойНадписи = Макет.ПолучитьОбласть("ОсновнаяНадпись");
	ОбластьОсновнойНадписи.Параметры.Наименование = "" + СокрЛП(Шапка.Наименование) + ФормированиеПечатныхФорм.ПредставлениеСерий(Шапка);
	
	ОбластьДанных = Макет.ПолучитьОбласть("Строка");
	
	МассивТаблиц = Новый Массив;
	МассивТаблиц.Добавить(ОбластьОсновнойНадписи);
	МассивТаблиц.Добавить(ОбластьДанных);
	МассивТаблиц.Добавить(ОбластьДанных);
	
	ТекВидНоменклатуры = "";
	Для Каждого СтрокаМатериалы Из ЗапросМатериалы Цикл 

		Если НЕ ЗначениеЗаполнено(СтрокаМатериалы.Номенклатура) Тогда
			ОбщегоНазначения.Сообщение("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		
		Если НЕ ФормированиеПечатныхФорм.ПроверитьВыводТабличногоДокумента(ТабДокумент, МассивТаблиц) Тогда

			ОбластьОсновнойНадписи.Параметры.Обозначение = "" + Шапка.Код + " " + Шапка.Обозначение;
			ОбластьОсновнойНадписи.Параметры.НомерСтраницы = НомерСтраницы;
			ТабДокумент.Вывести(ОбластьОсновнойНадписи);
			
			НомерСтраницы = НомерСтраницы + 1;
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			ТабДокумент.Вывести(ЗаголовокТаблицы);
			
			ОбластьОсновнойНадписи = Макет.ПолучитьОбласть("ОсновнаяНадписьВторойЛист");
			
			МассивТаблиц.Очистить();
			МассивТаблиц.Добавить(ОбластьОсновнойНадписи);
			МассивТаблиц.Добавить(ОбластьДанных);
			МассивТаблиц.Добавить(ОбластьДанных);
			
		КонецЕсли;
		
		Если ТекВидНоменклатуры <> СтрокаМатериалы.ВидНоменклатуры Тогда
			ТекВидНоменклатуры = СтрокаМатериалы.ВидНоменклатуры;
			
			Если Не ПустаяСтрока(ТекВидНоменклатуры) Тогда
				ОбластьВидаНоменклатуры = Макет.ПолучитьОбласть("СтрокаВидНоменклатуры");
				ОбластьВидаНоменклатуры.Параметры.Наименование = ТекВидНоменклатуры;
				ТабДокумент.Вывести(ОбластьВидаНоменклатуры);
			КонецЕсли;
			
		КонецЕсли;
		
		ОбластьДанных = Макет.ПолучитьОбласть("Строка");
		ОбластьДанных.Параметры.Позиция = ЗапросМатериалы.Индекс(СтрокаМатериалы) + 1;
		ОбластьДанных.Параметры.Заполнить(СтрокаМатериалы);
		ОбластьДанных.Параметры.Наименование = СокрЛП(СтрокаМатериалы.Наименование) + ФормированиеПечатныхФорм.ПредставлениеСерий(СтрокаМатериалы);
		ТабДокумент.Вывести(ОбластьДанных);

	КонецЦикла;
	
	Пока ФормированиеПечатныхФорм.ПроверитьВыводТабличногоДокумента(ТабДокумент, МассивТаблиц, Ложь) Цикл
			
		ОбластьДанных = Макет.ПолучитьОбласть("Строка");
		ОбластьДанных.ТекущаяОбласть.ВысотаСтроки = 24;
		ТабДокумент.Вывести(ОбластьДанных);
		
	КонецЦикла;
	
	Если НомерСтраницы = 1 Тогда
		ОбластьОсновнойНадписи = Макет.ПолучитьОбласть("ОсновнаяНадпись");
		ОбластьОсновнойНадписи.Параметры.Наименование = "" + Шапка.Наименование + ФормированиеПечатныхФорм.ПредставлениеСерий(Шапка);
	Иначе
		ОбластьОсновнойНадписи = Макет.ПолучитьОбласть("ОсновнаяНадписьВторойЛист");
	КонецЕсли;
	ОбластьОсновнойНадписи.Параметры.НомерСтраницы = НомерСтраницы;
	ОбластьОсновнойНадписи.Параметры.Обозначение = "" + Шапка.Код + " " + Шапка.Обозначение;
	ТабДокумент.Вывести(ОбластьОсновнойНадписи);
	
	ТабДокумент.Область("ВсегоСтраниц").Текст = НомерСтраницы;
		
	Возврат ТабДокумент;

КонецФункции // ПечатьСпецификацииГост()

// Процедура выводит в табличный документ раздел спецификации.
//
Процедура ВывестиРазделСпецификации(ТабДокумент, Макет, ВыборкаСтрок, ТекстЗаголовка)
	
	Если ВыборкаСтрок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ДопКолонка = Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	Колонка = "";
	Если ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Артикул Тогда
		ВыводитьКоды = Истина;
		Колонка = "Артикул";
	ИначеЕсли ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Код Тогда
		ВыводитьКоды = Истина;
		Колонка = "Код";
	Иначе
		ВыводитьКоды = Ложь;
	КонецЕсли;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаЗаголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ТекстЗаголовка;
	ТабДокумент.Вывести(ОбластьМакета);
	
	Область = Макет.ПолучитьОбласть(?(ВыводитьКоды, "ШапкаСКодом", "Шапка"));
	
	Если ВыводитьКоды Тогда
		Область.Параметры.ИмяКолонкиКодов = Колонка;
	КонецЕсли;
	ТабДокумент.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть(?(ВыводитьКоды, "СтрокаСКодом", "Строка"));

	Ном = 0;
	
	// Выборка выходных изделий.
	Пока ВыборкаСтрок.Следующий() Цикл
		
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрок.Номенклатура) Тогда
			ОбщегоНазначения.Сообщение("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		
		Ном = Ном + 1;
		
		Область.Параметры.Заполнить(ВыборкаСтрок);
		Область.Параметры.НомерСтроки = Ном;
		Если Колонка = "Артикул" Тогда
			Область.Параметры.Артикул = ВыборкаСтрок.Артикул;
		ИначеЕсли Колонка = "Код" Тогда
			Область.Параметры.Артикул = ВыборкаСтрок.Код;
		КонецЕсли;
		Область.Параметры.Номенклатура = СокрЛП(ВыборкаСтрок.Наименование) + ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрок);
		Область.Параметры.НоменклатураРасшифровка = ВыборкаСтрок.Номенклатура;
		ТабДокумент.Вывести(Область);
		
	КонецЦикла;
	
	// Вывести подвал
	Область = Макет.ПолучитьОбласть("Подвал");
	ТабДокумент.Вывести(Область);
		
КонецПроцедуры // ВывестиРазделСпецификации()

// Функция формирует табличный документ с печатной формой спецификации
// по ГОСТ 2.106-96.
//
// Возвращаемое значение:
//  Табличный документ - печатная форма спецификации
//
Функция ПечатьСпецификации()
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Спецификация";

	Макет = ПолучитьМакет("Спецификация");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СпецификацииНоменклатуры.Код 		 				КАК Код,
	|	СпецификацииНоменклатуры.Наименование 				КАК Наименование,
	|	СпецификацииНоменклатуры.Ответственный.Наименование КАК ОтветственныйНаименование
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры КАК СпецификацииНоменклатуры
	|ГДЕ
	|	СпецификацииНоменклатуры.Ссылка = &ТекущийЭлемент
	|";
	
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();
	
	// Выводим шапку накладной
	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = "Спецификация номенклатуры: " + Шапка.Наименование;
	ТабДокумент.Вывести(ОбластьМакета);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СпецификацииНоменклатуры.Номенклатура.Код 		 		КАК Код,
	|	СпецификацииНоменклатуры.Номенклатура.Артикул 		 	КАК Артикул,
	|	СпецификацииНоменклатуры.Номенклатура 					КАК Номенклатура,
	|	ВЫРАЗИТЬ(СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное КАК Строка(1000)) КАК Наименование,
	|	СпецификацииНоменклатуры.ХарактеристикаНоменклатуры 	КАК Характеристика,
	|	NULL 													КАК Серия,
	|	СпецификацииНоменклатуры.Количество 					КАК Количество,
	|	СпецификацииНоменклатуры.ЕдиницаИзмерения 				КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.ВыходныеИзделия КАК СпецификацииНоменклатуры
	|ГДЕ
	|	СпецификацииНоменклатуры.Ссылка = &ТекущийЭлемент
	|";
	
	ВыборкаСтрок = Запрос.Выполнить().Выбрать();
	
	ТекстЗаголовка = "Выходные изделия";
	ВывестиРазделСпецификации(ТабДокумент, Макет, ВыборкаСтрок, ТекстЗаголовка);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СпецификацииНоменклатуры.Номенклатура.Код 		 		КАК Код,
	|	СпецификацииНоменклатуры.Номенклатура.Артикул 		 	КАК Артикул,
	|	СпецификацииНоменклатуры.Номенклатура 					КАК Номенклатура,
	|	ВЫБОР КОГДА СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное ЕСТЬ NULL ТОГДА
	|		СпецификацииНоменклатуры.Номенклатура
	|	ИНАЧЕ
	|		ВЫРАЗИТЬ(СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное КАК Строка(1000))
	|	КОНЕЦ КАК Наименование,
	|	СпецификацииНоменклатуры.ХарактеристикаНоменклатуры 	КАК Характеристика,
	|	NULL 													КАК Серия,
	|	СпецификацииНоменклатуры.Количество 					КАК Количество,
	|	СпецификацииНоменклатуры.ЕдиницаИзмерения 				КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.ИсходныеКомплектующие КАК СпецификацииНоменклатуры
	|ГДЕ
	|	СпецификацииНоменклатуры.Ссылка = &ТекущийЭлемент
	|";
	
	ВыборкаСтрок = Запрос.Выполнить().Выбрать();
	
	ТекстЗаголовка = "Исходные комплектующие";
	ВывестиРазделСпецификации(ТабДокумент, Макет, ВыборкаСтрок, ТекстЗаголовка);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийЭлемент", ЭтотОбъект.Ссылка);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	СпецификацииНоменклатуры.Номенклатура.Код 		 		КАК Код,
	|	СпецификацииНоменклатуры.Номенклатура.Артикул 		 	КАК Артикул,
	|	СпецификацииНоменклатуры.Номенклатура 					КАК Номенклатура,
	|	ВЫБОР КОГДА СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное ЕСТЬ NULL ТОГДА
	|		СпецификацииНоменклатуры.Номенклатура
	|	ИНАЧЕ
	|		ВЫРАЗИТЬ(СпецификацииНоменклатуры.Номенклатура.НаименованиеПолное КАК Строка(1000))
	|	КОНЕЦ КАК Наименование,
	|	СпецификацииНоменклатуры.ХарактеристикаНоменклатуры 	КАК Характеристика,
	|	NULL 													КАК Серия,
	|	СпецификацииНоменклатуры.Количество 					КАК Количество,
	|	СпецификацииНоменклатуры.ЕдиницаИзмерения 				КАК ЕдиницаИзмерения
	|ИЗ
	|	Справочник.СпецификацииНоменклатуры.ВозвратныеОтходы КАК СпецификацииНоменклатуры
	|ГДЕ
	|	СпецификацииНоменклатуры.Ссылка = &ТекущийЭлемент
	|";
	
	ВыборкаСтрок = Запрос.Выполнить().Выбрать();
	
	ТекстЗаголовка = "Возвратные отходы";
	ВывестиРазделСпецификации(ТабДокумент, Макет, ВыборкаСтрок, ТекстЗаголовка);
	
	// Вывести подписи
	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);
			
	// Зададим параметры макета.
	ТабДокумент.ОбластьПечати = ТабДокумент.Область(2,2,ТабДокумент.ВысотаТаблицы, ТабДокумент.ШиринаТаблицы);
	ТабДокумент.ПолеСверху              = 5;
	ТабДокумент.ПолеСлева               = 15;
	ТабДокумент.ПолеСнизу               = 0;
	ТабДокумент.ПолеСправа              = 0;
	ТабДокумент.РазмерКолонтитулаСверху = 0;
	ТабДокумент.РазмерКолонтитулаСнизу  = 0;
	ТабДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Портрет;
	
	Возврат ТабДокумент;

КонецФункции // ПечатьСпецификации()

// Процедура осуществляет печать справочника. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт


		// Получить экземпляр документа на печать
	Если ИмяМакета = "Спецификация" Тогда
		
		ТабДокумент = ПечатьСпецификации();
		
	ИначеЕсли ИмяМакета = "СпецификацияГост" Тогда
		
		ТабДокумент = ПечатьСпецификацииГост();
		
	КонецЕсли;

	Заголовок = "Спецификация: " + Наименование;
	
	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, Заголовок, Ссылка);

КонецПроцедуры // Печать()

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("СпецификацияГост,Спецификация","ГОСТ 2.106-96","Спецификация");

КонецФункции // ПолучитьТаблицуПечатныхФорм()

#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)
	
	Если ТипЗнч(Основание) = Тип("СправочникСсылка.Номенклатура") Тогда
		
		НовоеИзделие = ВыходныеИзделия.Добавить();
		НовоеИзделие.Номенклатура 		= Основание;
		НовоеИзделие.ЕдиницаИзмерения 	= Основание.ЕдиницаХраненияОстатков;
		НовоеИзделие.Количество 		= 1;
		НовоеИзделие.ДоляСтоимости 		= 1;
		
	ИначеЕсли ТипЗнч(Основание) = Тип("СправочникСсылка.СпецификацииНоменклатуры") Тогда
		
		// Увеличим на единицу код версии.
		ОснованиеКодВерсии = Основание.КодВерсии;
		
		Если ПустаяСтрока(ОснованиеКодВерсии) Тогда
			ОснованиеКодВерсии = "00000";
		КонецЕсли;
		
		ЧислоКодВерсии = "";
		ПрефиксКодаВерсии = "";
		Для Сч = 1 По СтрДлина(ОснованиеКодВерсии) Цикл
			СимволКода = Сред(ОснованиеКодВерсии, Сч, 1);
			Если Найти("0123456789", СимволКода) > 0 Тогда
				ЧислоКодВерсии = ЧислоКодВерсии + СимволКода;
			Иначе
				ПрефиксКодаВерсии = ПрефиксКодаВерсии + СимволКода;
			КонецЕсли;
		КонецЦикла;
		ДлинаЧЦ = СтрДлина(ЧислоКодВерсии);
		ЧислоКодВерсии = Формат(Число(ЧислоКодВерсии) + 1, "ЧЦ="+ДлинаЧЦ+";ЧВН=;ЧГ=");
		
		// Заполнение реквизитов шапки спецификации.
		Родитель = Основание.Родитель;
		Код = Основание.Код;
		КодВерсии = ПрефиксКодаВерсии + Строка(ЧислоКодВерсии);
		Наименование = Основание.Наименование;
		ВидСпецификации = Основание.ВидСпецификации;
		
		ИспользоватьВозвратныеОтходы = Основание.ИспользоватьВозвратныеОтходы;
		ИспользоватьПараметрыВыпускаПродукции = Основание.ИспользоватьПараметрыВыпускаПродукции;
		ИспользоватьДокументацию = Основание.ИспользоватьДокументацию;
		ИспользоватьВидНорматива = Основание.ИспользоватьВидНорматива;
		ИспользоватьВидВоспроизводства = Основание.ИспользоватьВидВоспроизводства;
		ИспользоватьУказаниеНорматива = Основание.ИспользоватьУказаниеНорматива;
		ИспользоватьФормулы = Основание.ИспользоватьФормулы;
		ИспользоватьУправлениеСписанием = Основание.ИспользоватьУправлениеСписанием;
		
		ВыходныеИзделия.Загрузить(Основание.ВыходныеИзделия.Выгрузить());
		ИсходныеКомплектующие.Загрузить(Основание.ИсходныеКомплектующие.Выгрузить());
		ВозвратныеОтходы.Загрузить(Основание.ВозвратныеОтходы.Выгрузить());
		ПараметрыВыпускаПродукции.Загрузить(Основание.ПараметрыВыпускаПродукции.Выгрузить());
		Документация.Загрузить(Основание.Документация.Выгрузить());
		АвтоподборНоменклатуры.Загрузить(Основание.АвтоподборНоменклатуры.Выгрузить());
		АвтоподборХарактеристики.Загрузить(Основание.АвтоподборХарактеристики.Выгрузить());
		АвтоподборНоменклатурыОтходы.Загрузить(Основание.АвтоподборНоменклатурыОтходы.Выгрузить());
		АвтоподборХарактеристикиОтходы.Загрузить(Основание.АвтоподборХарактеристикиОтходы.Выгрузить());
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаЗаполнения()


// Процедура - обработчик события "ПередЗаписью".
//
Процедура ПередЗаписью(Отказ)
	Если ЭтоГруппа Тогда Возврат; КонецЕсли;
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ВидСпецификации <> Перечисления.ВидыСпецификаций.Узел Тогда                                                            
		Для каждого Продукция Из ВыходныеИзделия Цикл
			Если НЕ ЗначениеЗаполнено(Продукция.ЕдиницаИзмерения) Тогда  
				СтрокаСообщения = "Для продукции """ + Продукция.Номенклатура + """ не заполнена единица измерения";
				ОбщегоНазначения.СообщитьОбОшибке(СтрокаСообщения, Отказ); 		
			КонецЕсли;  	
		КонецЦикла; 
	КонецЕсли; 
	
	Если Не ИспользоватьВидНорматива 
	 ИЛИ Не ИспользоватьУказаниеНорматива
	 ИЛИ Не ИспользоватьУправлениеСписанием Тогда
	 
		Для Каждого Строка Из ИсходныеКомплектующие Цикл
			Если Не ИспользоватьВидНорматива И НЕ ЗначениеЗаполнено(Строка.ВидНорматива) Тогда
				Строка.ВидНорматива = Перечисления.ВидыНормативовНоменклатуры.Номенклатура;
			КонецЕсли;
		 	Если Не ИспользоватьУказаниеНорматива И НЕ ЗначениеЗаполнено(Строка.УказаниеНорматива) Тогда
				Строка.УказаниеНорматива = Перечисления.ВидыУказанияНорматива.НаКоличествоПродукции;
			КонецЕсли;
			Если Не ИспользоватьУправлениеСписанием И НЕ ЗначениеЗаполнено(Строка.СписаниеКомплектующей) Тогда
				Строка.СписаниеКомплектующей = Перечисления.ВариантыСписанияКомплектующих.Всегда;
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого Строка Из ВозвратныеОтходы Цикл
			Если Не ИспользоватьВидНорматива И НЕ ЗначениеЗаполнено(Строка.ВидНорматива) Тогда
				Строка.ВидНорматива = Перечисления.ВидыНормативовНоменклатуры.Номенклатура;
			КонецЕсли;
		 	Если Не ИспользоватьУказаниеНорматива И НЕ ЗначениеЗаполнено(Строка.УказаниеНорматива) Тогда
				Строка.УказаниеНорматива = Перечисления.ВидыУказанияНорматива.НаКоличествоПродукции;
			КонецЕсли;
			Если Не ИспользоватьУправлениеСписанием И НЕ ЗначениеЗаполнено(Строка.СписаниеКомплектующей) Тогда
				Строка.СписаниеКомплектующей = Перечисления.ВариантыСписанияКомплектующих.Всегда;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	УчетСерийныхНомеров.УдалитьНеиспользуемыеСтрокиПодчиненнойТЧ(ЭтотОбъект, мПараметрыСвязиСтрокТЧ, "ИсходныеКомплектующие", "АвтоподборНоменклатуры");
	УчетСерийныхНомеров.УдалитьНеиспользуемыеСтрокиПодчиненнойТЧ(ЭтотОбъект, мПараметрыСвязиСтрокТЧ, "ИсходныеКомплектующие", "АвтоподборХарактеристики");
	УчетСерийныхНомеров.УдалитьНеиспользуемыеСтрокиПодчиненнойТЧ(ЭтотОбъект, мПараметрыСвязиСтрокТЧ, "ВозвратныеОтходы", "АвтоподборНоменклатурыОтходы");
	УчетСерийныхНомеров.УдалитьНеиспользуемыеСтрокиПодчиненнойТЧ(ЭтотОбъект, мПараметрыСвязиСтрокТЧ, "ВозвратныеОтходы", "АвтоподборХарактеристикиОтходы");
	
КонецПроцедуры // ПередЗаписью()

мПараметрыСвязиСтрокТЧ = Новый Соответствие;
мПараметрыСвязиСтрокТЧ.Вставить("ИсходныеКомплектующие", Новый Структура("СвободныйКлюч, ФлагМодификации", Неопределено, Ложь));
мПараметрыСвязиСтрокТЧ.Вставить("ВозвратныеОтходы", Новый Структура("СвободныйКлюч, ФлагМодификации", Неопределено, Ложь));
