Перем мУдалятьДвижения;

// Хранит структуру, содержащую параметры для определения договора, доступного в данном документе:
//    список допустимых видов договоров;
//    список допустимых способов ведения взаиморасчетов.
Перем мСтруктураПараметровДляПолученияДоговора Экспорт;


////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой накладной,
// разработанной методистами
//
// Возвращаемое значение:
//  Табличный документ - печатная форма накладной
//
Функция ПечатьДокумента()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	ДоговорКонтрагента,
	|	ДоговорКонтрагента.ВедениеВзаиморасчетов КАК ДоговорВедениеВзаиморасчетов,
	|	ДоговорКонтрагента.НаименованиеДляПечати КАК ДоговорНаименованиеДляПечати,	
	|	ДоговорКонтрагента.ВыводитьИнформациюОСделкеПриПечатиДокументов КАК ПечататьСделку,	
	|	Сделка,
	|	Контрагент КАК Покупатель,
	|	Организация,
	|	Организация КАК Поставщик,
	|	Ответственный.ФизЛицо.Наименование КАК Выписал
	|ИЗ
	|	Документ.ИнвентаризацияТоваровОтданныхНаКомиссию КАК ИнвентаризацияТоваровОтданныхНаКомиссию
	|
	|ГДЕ
	|	ИнвентаризацияТоваровОтданныхНаКомиссию.Ссылка = &ТекущийДокумент";
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	НомерСтроки КАК НомерСтрокиТЧ,
	|	Номенклатура,
	|	ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК СТРОКА(1000))  КАК Товар,
	|	Количество,
	|	КоличествоМест,
	|	ЕдиницаИзмеренияМест.Представление КАК ЕдиницаИзмеренияМест,
	|	ЕдиницаИзмерения.Представление КАК ЕдиницаИзмерения,
	|	ХарактеристикаНоменклатуры КАК Характеристика,
	|	СерияНоменклатуры КАК Серия
	|ИЗ
	|	Документ.ИнвентаризацияТоваровОтданныхНаКомиссию.Товары КАК ИнвентаризацияТоваровОтданныхНаКомиссию
	|
	|ГДЕ
	|	ИнвентаризацияТоваровОтданныхНаКомиссию.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтрокиТЧ
	|";
	ЗапросТовары = Запрос.Выполнить().Выгрузить();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияТоваровОтданныхНаКомиссию_ИнвентаризацияТоваровНаКомисии";
	Макет = ПолучитьМакет("ИнвентаризацияТоваровНаКомисии");
	
	// печать производится на языке, указанном в настройках пользователя
	КодЯзыкаПечать = Локализация.ПолучитьЯзыкФормированияПечатныхФорм(УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "РежимФормированияПечатныхФорм"));
	Макет.КодЯзыкаМакета = КодЯзыкаПечать;
	
	// Выводим шапку накладной
	СведенияОПоставщике = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Поставщик, Шапка.Дата,,,КодЯзыкаПечать);
	СведенияОПокупателе = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Покупатель, Шапка.Дата,,,КодЯзыкаПечать);
	
	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, НСтр("ru='Инвентаризация товаров отданных на комиссию';uk='Інвентаризація товарів відданих на комісію'",КодЯзыкаПечать)+ Символы.ПС,КодЯзыкаПечать);
	ТабДокумент.Вывести(ОбластьМакета);


	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,",,КодЯзыкаПечать);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеПокупателя = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОПокупателе, "ПолноеНаименование,",,КодЯзыкаПечать);
	ТабДокумент.Вывести(ОбластьМакета);

	// Выводим дополнительно информацию о договоре и сделке
	СписокДополнительныхПараметров = "ДоговорНаименованиеДляПечати,";
	Если Шапка.ПечататьСделку = Истина Тогда
		СписокДополнительныхПараметров = СписокДополнительныхПараметров + "Сделка,";
	КонецЕсли;
	МассивСтруктурСтрок = ФормированиеПечатныхФорм.ДополнительнаяИнформация(Шапка,СписокДополнительныхПараметров,КодЯзыкаПечать);
	ОбластьМакета = Макет.ПолучитьОбласть("ДопИнформация");
	Для каждого СтруктураСтроки Из МассивСтруктурСтрок Цикл
		ОбластьМакета.Параметры.Заполнить(СтруктураСтроки);
		ТабДокумент.Вывести(ОбластьМакета);
	КонецЦикла;

	// Выводим шапку талицы
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	//выводим таблицу
	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	Для каждого ВыборкаСтрокТовары из ЗапросТовары Цикл		

		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Номенклатура) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;
		
		ОбластьМакета.Параметры.НомерСтроки = ЗапросТовары.Индекс(ВыборкаСтрокТовары) + 1;		
		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьМакета.Параметры.Товар = СокрП(ВыборкаСтрокТовары.Товар) + ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрокТовары);

		ТабДокумент.Вывести(ОбластьМакета);

	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	МестВсего = ЗапросТовары.Итог("КоличествоМест");
    Если МестВсего = 0 Тогда
		УниверсальныеМеханизмы.СкрытьКолонкиВТабличномДокументе(ТабДокумент, "Мест",1, "ШапкаТаблицы");
    КонецЕсли;                                                   
	
	Возврат ТабДокумент;

КонецФункции // ПечатьДокумента()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт

	Если ЭтоНовый() Тогда
		Предупреждение("Документ можно распечатать только после его записи");
		Возврат;
	КонецЕсли;

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	Если ИмяМакета = "Накладная" Тогда
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьДокумента();
		
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("Накладная", "Инвентаризация товаров отданных на комиссию");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()



// Процедура выполняет заполнение табличной части. Если передан документ основание то
//  заполнение производится по документу основанию, иначе по всем.
//
Процедура ЗаполнитьТовары(ДокументОснование = Неопределено) Экспорт

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДоговорКонтрагента", ДоговорКонтрагента);
	Запрос.УстановитьПараметр("НаКомиссию", Перечисления.СтатусыПолученияПередачиТоваров.НаКомиссию);
	Запрос.УстановитьПараметр("ДатаОстатков", ОбщегоНазначения.ПолучитьДатуОстатков(ЭтотОбъект));
	Если НЕ ЗначениеЗаполнено(Сделка) Тогда
		Запрос.УстановитьПараметр("Сделка", Неопределено);
	Иначе		
		Запрос.УстановитьПараметр("Сделка", Сделка);
	КонецЕсли;

	Запрос.Текст =
	"ВЫБРАТЬ
	|	Остатки.ДоговорКонтрагента,
	|	Остатки.Сделка,
	|	Остатки.Номенклатура,
	|	Остатки.ХарактеристикаНоменклатуры,
	|	Остатки.СерияНоменклатуры,
	|	СУММА(Остатки.КоличествоОстаток) КАК КоличествоОстаток,
	|	СУММА(Остатки.СуммаВзаиморасчетовОстаток) КАК СтоимостьОстаток
	|ИЗ
	|	РегистрНакопления.ТоварыПереданные.Остатки(&ДатаОстатков,
	|                                   ДоговорКонтрагента = &ДоговорКонтрагента И СтатусПередачи = &НаКомиссию
	|                                   И Сделка = &Сделка) КАК Остатки
	|ГДЕ
	| 	Остатки.КоличествоОстаток > 0
	|
	|СГРУППИРОВАТЬ ПО
	|	Остатки.ДоговорКонтрагента,
	|	Остатки.Сделка,
	|	Остатки.Номенклатура,
	|	Остатки.ХарактеристикаНоменклатуры,
	|	Остатки.СерияНоменклатуры
	|";

	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл

		СтрокаТабличнойЧасти = Товары.Добавить();

		СтрокаТабличнойЧасти.Номенклатура               = Выборка.Номенклатура;
		СтрокаТабличнойЧасти.ЕдиницаИзмерения           = СтрокаТабличнойЧасти.Номенклатура.ЕдиницаХраненияОстатков;
		СтрокаТабличнойЧасти.Коэффициент                = СтрокаТабличнойЧасти.ЕдиницаИзмерения.Коэффициент;
		СтрокаТабличнойЧасти.Количество                 = Выборка.КоличествоОстаток;
		СтрокаТабличнойЧасти.КоличествоУчет             = Выборка.КоличествоОстаток;
		СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Выборка.ХарактеристикаНоменклатуры;
		СтрокаТабличнойЧасти.СерияНоменклатуры          = Выборка.СерияНоменклатуры;

	КонецЦикла;

КонецПроцедуры // ЗаполнитьТовары()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

	// Проверка заполнения единицы измерения мест и количества мест
	ОбработкаТабличныхЧастей.ПриЗаписиПроверитьЕдиницуИзмеренияМест(Товары);
	
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью


Процедура ПриЗаписи(Отказ)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

КонецПроцедуры


мСтруктураПараметровДляПолученияДоговора = Новый Структура();
мСписокДопустимыхВидовДоговоров = Новый СписокЗначений();
мСписокДопустимыхВидовДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером);
мСтруктураПараметровДляПолученияДоговора.Вставить("СписокДопустимыхВидовДоговоров", мСписокДопустимыхВидовДоговоров);