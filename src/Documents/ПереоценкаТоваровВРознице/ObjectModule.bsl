Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;

// Флаги принадлежности к виду операции.
Перем мВидОперацииНТТ Экспорт;
Перем мВидОперацииРозница Экспорт;

Перем мРазрешитьНулевыеЦеныВРознице Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Процедура устанавливает флаги принадлежности к виду операции.
//
Процедура УстановитьФлагиВидаОперации() Экспорт

	мВидОперацииНТТ = (ВидОперации = Перечисления.ВидыОперацийПереоценкаТоваровВРознице.ПереоценкаВНТТ);
	мВидОперацииРозница = (ВидОперации = Перечисления.ВидыОперацийПереоценкаТоваровВРознице.ПереоценкаВРознице);

КонецПроцедуры // УстановитьФлагиВидаОперации()

#Если Клиент Тогда
// Функция формирует табличный документ с печатной формой переоценки в НТТ.
//
// Возвращаемое значение:
//  Табличный документ.
//
Функция ПечатьПереоценкиТоваровВНТТ()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	Организация,
	|	Организация         КАК Поставщик,
	|	Склад               КАК Получатель,
	|	Склад.Представление КАК ПредставлениеПолучателя,
	|	Товары.(
	|		НомерСтроки,
	|		Количество,
	|		Номенклатура,
	|		Номенклатура.НаименованиеПолное КАК Товар,
	|		Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаИзмерения,
	|		Номенклатура.ЕдиницаХраненияОстатков.Коэффициент,
	|		ЦенаВРозницеСтарая,
	|		ЦенаВРознице,
	|		(ЦенаВРознице - ЦенаВРозницеСтарая) * Количество КАК ОтклонениеСтоимости,
	|		ХарактеристикаНоменклатуры КАК Характеристика,
	|		СерияНоменклатуры КАК Серия
	|	)
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице КАК ПереоценкаТоваровВРознице
	|ГДЕ
	|	ПереоценкаТоваровВРознице.Ссылка = &ТекущийДокумент
	|УПОРЯДОЧИТЬ ПО
	|	Товары.НомерСтроки";

	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПереоценкаТоваровВРознице_ПереоценкаТоваровВРознице";
	Макет = ПолучитьМакет("ПереоценкаТоваровВРознице");

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, "Переоценка товаров в рознице");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата), "ПолноеНаименование,");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	ИтогОтклонениеСтоимости = 0;
	ВыборкаСтрокТовары = Шапка.Товары.Выбрать();
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Товар) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьМакета.Параметры.Товар = ВыборкаСтрокТовары.Товар + ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрокТовары);
		ТабДокумент.Вывести(ОбластьМакета);

		ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости + ВыборкаСтрокТовары.ОтклонениеСтоимости;
	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итог");
	ОбластьМакета.Параметры.ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // ПечатьПереоценкиТоваровВНТТ()

// Функция формирует табличный документ с печатной формой переоценки в рознице.
//
// Возвращаемое значение:
//  Табличный документ.
//
Функция ПечатьПереоценкиТоваровВРознице()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокСсылка", Ссылка);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("ПустаяХарактеристика", Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка());
	Запрос.УстановитьПараметр("СписокНоменклатуры", Товары.ВыгрузитьКолонку("Номенклатура"));
	Запрос.УстановитьПараметр("СписокХарактеристик", Товары.ВыгрузитьКолонку("ХарактеристикаНоменклатуры"));
	Запрос.УстановитьПараметр("Дата", Дата);

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	Док.Ссылка.Номер,
	|	Док.Ссылка.Дата,
	|	Док.Ссылка.Организация,
	|	Док.Ссылка.Организация КАК Поставщик,
	|	Док.Ссылка.Склад КАК Получатель,
	|	Док.Ссылка.Склад.Представление КАК ПредставлениеПолучателя,
	|	ТоварыВРознице.НомерСтроки,
	|	Остатки.КоличествоОстаток КАК Количество,
	|	ТоварыВРознице.Номенклатура,
	|	ТоварыВРознице.Номенклатура.НаименованиеПолное КАК Товар,
	|	ТоварыВРознице.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаИзмерения,
	|	ТоварыВРознице.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент,
	|	Остатки.СуммаПродажнаяОстаток / Остатки.КоличествоОстаток КАК ЦенаВРозницеСтарая,
	|	Док.ЦенаВРознице,
	|	ТоварыВРознице.СуммаПродажная КАК ОтклонениеСтоимости,
	|	ТоварыВРознице.ХарактеристикаНоменклатуры КАК Характеристика,
	|	ТоварыВРознице.СерияНоменклатуры КАК Серия
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице.Товары КАК Док
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	(ВЫБРАТЬ
	|		Характеристики.Ссылка КАК Ссылка,
	|		Характеристики.Владелец КАК Владелец
	|	ИЗ
	|		Справочник.ХарактеристикиНоменклатуры КАК Характеристики
	|	ГДЕ
	|		Характеристики.Владелец В (&СписокНоменклатуры)
	|		И Характеристики.Ссылка НЕ В (&СписокХарактеристик)
	|		И Характеристики.Ссылка НЕ В (
	|			ВЫБРАТЬ
	|				ЦеныПродажные.ХарактеристикаНоменклатуры
	|			ИЗ
	|				РегистрСведений.ЦеныАТТ.СрезПоследних(&Дата,
	|				   Номенклатура В (&СписокНоменклатуры)) КАК ЦеныПродажные
	|		)
	|	ОБЪЕДИНИТЬ ВСЕ
	|	ВЫБРАТЬ
	|		&ПустаяХарактеристика КАК Ссылка,
	|		Номенклатура.Ссылка КАК Владелец
	|	ИЗ
	|		Справочник.Номенклатура КАК Номенклатура
	|	ГДЕ
	|		Номенклатура.Ссылка В (&СписокНоменклатуры)
	|	) КАК Характеристики
	|ПО
	|	Док.Номенклатура = Характеристики.Владелец
	|	И Док.ХарактеристикаНоменклатуры = &ПустаяХарактеристика
	|СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыВРознице.Остатки(&Дата, Склад = &Склад И Номенклатура В (&СписокНоменклатуры)) КАК Остатки
	|ПО
	|	Док.Номенклатура = Остатки.Номенклатура
	|	И ЕСТЬNULL(Характеристики.Ссылка, Док.ХарактеристикаНоменклатуры) = Остатки.ХарактеристикаНоменклатуры
	|СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыВРознице КАК ТоварыВРознице
	|ПО
	|	Док.Ссылка = ТоварыВРознице.Регистратор
	|	И Док.Номенклатура = ТоварыВРознице.Номенклатура
	|	И ЕСТЬNULL(Характеристики.Ссылка, Док.ХарактеристикаНоменклатуры) = ТоварыВРознице.ХарактеристикаНоменклатуры
	|ГДЕ
	|	Док.Ссылка = &ДокСсылка
	|УПОРЯДОЧИТЬ ПО
	|	ТоварыВРознице.НомерСтроки
	|";

	Запрос.Текст = ТекстЗапроса;

	Шапка = Запрос.Выполнить().Выбрать();
	Если Не Шапка.Следующий() Тогда
		Предупреждение("Ни один товар не был переоценен.");
		Возврат Неопределено;
	КонецЕсли;

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ПереоценкаТоваровВРознице_ПереоценкаТоваровВРознице";
	Макет = ПолучитьМакет("ПереоценкаТоваровВРознице");

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, "Переоценка товаров в рознице");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ФормированиеПечатныхФорм.ОписаниеОрганизации(УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата), "ПолноеНаименование,");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Строка");

	ИтогОтклонениеСтоимости = 0;
	ВыборкаСтрокТовары = Шапка;
	ВыборкаСтрокТовары.Сбросить();
	Пока ВыборкаСтрокТовары.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаСтрокТовары.Товар) Тогда
			Сообщить("В одной из строк не заполнено значение номенклатуры - строка при печати пропущена.", СтатусСообщения.Важное);
			Продолжить;
		КонецЕсли;

		ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
		ОбластьМакета.Параметры.Товар = ВыборкаСтрокТовары.Товар + ФормированиеПечатныхФорм.ПредставлениеСерий(ВыборкаСтрокТовары);
		ТабДокумент.Вывести(ОбластьМакета);

		ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости + ВыборкаСтрокТовары.ОтклонениеСтоимости;
	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итог");
	ОбластьМакета.Параметры.ИтогОтклонениеСтоимости = ИтогОтклонениеСтоимости;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // ПечатьПереоценкиТоваровВНТТ()

// Функция печатает ценники.
//
Функция ПечатьЦенников()

	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	ИСТИНА КАК Печать,
	|	Док.Номенклатура КАК Номенклатура,
	|	Док.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков КАК ЕдиницаИзмерения,
	|	Док.ЦенаВРознице КАК Цена,
	|	1 КАК Количество
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице.Товары КАК Док
	|ГДЕ
	|	Док.Ссылка = &Док
	|");

	Запрос.УстановитьПараметр("Док", Ссылка);

	ОбработкаПечатьЦенников = Обработки.ПечатьЦенников.Создать();
	ОбработкаПечатьЦенников.Товары.Загрузить(Запрос.Выполнить().Выгрузить());

	ФормаПечатьЦенников = ОбработкаПечатьЦенников.ПолучитьФорму("Форма");
	ФормаПечатьЦенников.Открыть();

КонецФункции // ПечатьЦенников()

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
	
	//перезаполнение переменных на случай запуска из формы списка
    мВидОперацииНТТ = (ВидОперации = Перечисления.ВидыОперацийПереоценкаТоваровВРознице.ПереоценкаВНТТ);
	мВидОперацииРозница = (ВидОперации = Перечисления.ВидыОперацийПереоценкаТоваровВРознице.ПереоценкаВРознице);
	
	Если мВидОперацииНТТ Тогда
		Если ЭтоНовый() Тогда
			Предупреждение("Документ можно распечатать только после его записи");
			Возврат;
		ИначеЕсли Не УправлениеДопПравамиПользователей.РазрешитьПечатьНепроведенныхДокументов(Проведен) Тогда
			Предупреждение("Недостаточно полномочий для печати непроведенного документа!");
			Возврат;
		КонецЕсли;
	ИначеЕсли мВидОперацииРозница Тогда
		Если Не Проведен Тогда
			Предупреждение("Документ можно распечатать только после его проведения");
			Возврат;
		КонецЕсли;
	КонецЕсли;

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	// Получить экземпляр документа на печать
	Если ИмяМакета = "ПереоценкаТоваровВРознице" Тогда
		Если мВидОперацииНТТ Тогда
			ТабДокумент = ПечатьПереоценкиТоваровВНТТ();
		ИначеЕсли мВидОперацииРозница Тогда
			ТабДокумент = ПечатьПереоценкиТоваровВРознице();
		КонецЕсли;
	ИначеЕсли ИмяМакета = "Ценники" Тогда
		ТабДокумент = ПечатьЦенников();
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда
		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);

		Если ТабДокумент = Неопределено Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), Ссылка);

КонецПроцедуры // Печать()

// Возвращает доступные варианты печати документа.
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати.
//
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт

	СтруктураМакетов = Новый Структура("ПереоценкаТоваровВРознице", "Переоценка товаров в рознице");
	СтруктураМакетов.Вставить("Ценники", "Ценники на товары");

	Возврат СтруктураМакетов;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Процедура выполняет заполнение табличной части.
//
Процедура ЗаполнитьТовары(РежимЗаполнения = "ЗаполнитьПоОстаткам") Экспорт

	Если РежимЗаполнения = "ЗаполнитьИзУстановкиЦен" Тогда
		Если НЕ ЗначениеЗаполнено(ДокументУстановкаЦен) Тогда
			Предупреждение("Не выбран документ установки цен!");
			Возврат;
		КонецЕсли;

		Запрос = Новый Запрос("
		|ВЫБРАТЬ
		|	УстановкаЦен.Номенклатура КАК Номенклатура,
		|	УстановкаЦен.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	УстановкаЦен.Цена
		|	   / УстановкаЦен.ЕдиницаИзмерения.Коэффициент
		|	   * УстановкаЦен.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент
		|	   * КурсыВалют.Курс
		|	   / КурсыВалют.Кратность КАК ЦенаВРознице
		|ИЗ
		|	Документ.УстановкаЦенНоменклатуры.Товары КАК УстановкаЦен
		|ЛЕВОЕ СОЕДИНЕНИЕ
		|	РегистрСведений.КурсыВалют.СрезПоследних(&Дата) КАК КурсыВалют
		|ПО
		|	КурсыВалют.Валюта = УстановкаЦен.Валюта 
		|ГДЕ
		|	УстановкаЦен.Ссылка = &Док
		|	И УстановкаЦен.ТипЦен = &ТипЦен
		|");

		Запрос.УстановитьПараметр("ТипЦен", Склад.ТипЦенРозничнойТорговли);
		Запрос.УстановитьПараметр("Док"   , ДокументУстановкаЦен);
		Запрос.УстановитьПараметр("Дата"  , Дата);

		Товары.Загрузить(Запрос.Выполнить().Выгрузить());
	Иначе

		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Склад", Склад);
		Запрос.УстановитьПараметр("Товар", Перечисления.ТоварТара.Товар);
		Запрос.УстановитьПараметр("ДатаОстатков", ОбщегоНазначения.ПолучитьДатуОстатков(ЭтотОбъект));

		Запрос.Текст =
		"ВЫБРАТЬ
		|	Остатки.Номенклатура,
		|	Остатки.ЦенаВРознице,
		|	Остатки.ХарактеристикаНоменклатуры,
		|	Остатки.СерияНоменклатуры,
		|	СУММА(Остатки.КоличествоОстаток) КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ТоварыВНТТ.Остатки(&ДатаОстатков,
		|	   Склад = &Склад И ТоварТара = &Товар) КАК Остатки
		|ГДЕ
		|	Остатки.КоличествоОстаток > 0
		|СГРУППИРОВАТЬ ПО
		|	Остатки.Номенклатура,
		|	Остатки.ЦенаВРознице,
		|	Остатки.ХарактеристикаНоменклатуры,
		|	Остатки.СерияНоменклатуры
		|";

		Выборка        = Запрос.Выполнить().Выбрать();
		ТипЦенСклада   = Склад.ТипЦенРозничнойТорговли;
		Валюта         = мВалютаРегламентированногоУчета;
		СтруктураКурса = МодульВалютногоУчета.ПолучитьКурсВалюты(Валюта, Дата);
		Курс           = СтруктураКурса.Курс;
		Кратность      = СтруктураКурса.Кратность;

		Пока Выборка.Следующий() Цикл

			ДобавитьСтроку     = Истина;
			Номенклатура       = Выборка.Номенклатура;
			Характеристика     = Выборка.ХарактеристикаНоменклатуры;
			Серия              = Выборка.СерияНоменклатуры;
			Количество         = Выборка.КоличествоОстаток;
			ЦенаВРозницеСтарая = Выборка.ЦенаВРознице;

			Если РежимЗаполнения = "ЗаполнитьПоЦенам" Тогда
				ЦенаПоТипуЦен = Ценообразование.ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика, ТипЦенСклада,
				                Дата, Номенклатура.ЕдиницаХраненияОстатков, Валюта, Курс, Кратность);

				Если ЦенаПоТипуЦен > 0
				   И ЦенаПоТипуЦен <> ЦенаВРозницеСтарая Тогда
					ЦенаВРознице = ЦенаПоТипуЦен;
				Иначе
					ДобавитьСтроку = Ложь;
				КонецЕсли;
			Иначе
				ЦенаВРознице = ЦенаВРозницеСтарая;
			КонецЕсли;

			Если ДобавитьСтроку Тогда

				СтрокаТабличнойЧасти = Товары.Добавить();
				СтрокаТабличнойЧасти.Номенклатура               = Номенклатура;
				СтрокаТабличнойЧасти.ХарактеристикаНоменклатуры = Характеристика;
				СтрокаТабличнойЧасти.СерияНоменклатуры          = Серия;
				СтрокаТабличнойЧасти.Количество                 = Количество;
				СтрокаТабличнойЧасти.ЦенаВРозницеСтарая         = ЦенаВРозницеСтарая;
				СтрокаТабличнойЧасти.ЦенаВРознице               = ЦенаВРознице;
				СтрокаТабличнойЧасти.ЕдиницаИзмерения 	= СтрокаТабличнойЧасти.Номенклатура.ЕдиницаХраненияОстатков;
				СтрокаТабличнойЧасти.Коэффициент 		= СтрокаТабличнойЧасти.ЕдиницаИзмерения.Коэффициент;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // ЗаполнитьТовары()
#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Формирует таблицу товаров для переоценки.
//
// Возвращаемое значение:
//  ТаблицаЗначений - таблица значений, содержащая информацию для движений по переоценке.
//
Функция ПодготовитьТаблицуПереоценки()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокСсылка", Ссылка);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("ПустаяХарактеристика", Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка());
	Запрос.УстановитьПараметр("Дата", Дата);
	
	ТекстЗапросаСписокНоменклатуры = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	                                 |	ПереоценкаТоваровВРозницеТовары.Номенклатура
	                                 |ИЗ
	                                 |	Документ.ПереоценкаТоваровВРознице.Товары КАК ПереоценкаТоваровВРозницеТовары
	                                 |ГДЕ
	                                 |	ПереоценкаТоваровВРозницеТовары.Ссылка = &ДокСсылка";
									 
	ТекстЗапросаСписокХарактеристик ="ВЫБРАТЬ РАЗЛИЧНЫЕ
	                                 |	ПереоценкаТоваровВРозницеТовары.ХарактеристикаНоменклатуры
	                                 |ИЗ
	                                 |	Документ.ПереоценкаТоваровВРознице.Товары КАК ПереоценкаТоваровВРозницеТовары
	                                 |ГДЕ
	                                 |	ПереоценкаТоваровВРозницеТовары.Ссылка = &ДокСсылка";									 
	

	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	&Склад КАК Склад,
	|	Док.Номенклатура КАК Номенклатура,
	|	ЕСТЬNULL(Характеристики.Ссылка, Док.ХарактеристикаНоменклатуры) КАК ХарактеристикаНоменклатуры,
	|	Остатки.СерияНоменклатуры КАК СерияНоменклатуры,
	|	Остатки.Качество КАК Качество,
	|	Док.ЦенаВРознице * Остатки.КоличествоОстаток - Остатки.СуммаПродажнаяОстаток КАК СуммаПродажная
	|ИЗ
	|	Документ.ПереоценкаТоваровВРознице.Товары КАК Док
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	(ВЫБРАТЬ
	|		Характеристики.Ссылка КАК Ссылка,
	|		Характеристики.Владелец КАК Владелец
	|	ИЗ
	|		Справочник.ХарактеристикиНоменклатуры КАК Характеристики
	|	ГДЕ
	|		Характеристики.Владелец В (" + ТекстЗапросаСписокНоменклатуры + ")
	|		И Характеристики.Ссылка НЕ В (" + ТекстЗапросаСписокХарактеристик + ")
	|		И Характеристики.Ссылка НЕ В (
	|			ВЫБРАТЬ
	|				ЦеныПродажные.ХарактеристикаНоменклатуры
	|			ИЗ
	|				РегистрСведений.ЦеныАТТ.СрезПоследних(&Дата,
	|				   Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")) КАК ЦеныПродажные
	|		)
	|	ОБЪЕДИНИТЬ ВСЕ
	|	ВЫБРАТЬ
	|		&ПустаяХарактеристика КАК Ссылка,
	|		Номенклатура.Ссылка КАК Владелец
	|	ИЗ
	|		Справочник.Номенклатура КАК Номенклатура
	|	ГДЕ
	|		Номенклатура.Ссылка В (" + ТекстЗапросаСписокНоменклатуры + ")
	|	) КАК Характеристики
	|ПО
	|	Док.Номенклатура = Характеристики.Владелец
	|	И Док.ХарактеристикаНоменклатуры = &ПустаяХарактеристика
	|СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыВРознице.Остатки(&Дата, Склад = &Склад И Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")) КАК Остатки
	|ПО
	|	Док.Номенклатура = Остатки.Номенклатура
	|	И ЕСТЬNULL(Характеристики.Ссылка, Док.ХарактеристикаНоменклатуры) = Остатки.ХарактеристикаНоменклатуры
	|ГДЕ
	|	Док.Ссылка = &ДокСсылка
	|	И Док.ЦенаВРознице * Остатки.КоличествоОстаток - Остатки.СуммаПродажнаяОстаток <> 0
	|";

	Запрос.Текст = ТекстЗапроса;

	ТаблицаПереоценки = Запрос.Выполнить().Выгрузить();

	Возврат ТаблицаПереоценки;

КонецФункции // ПодготовитьТаблицуПереоценки()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры:
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары".
//  СтруктураШапкиДокумента   - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблица значений.
//
Функция ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента)

	ТаблицаТоваров = РезультатЗапросаПоТоварам.Выгрузить();

	Если мВидОперацииНТТ Тогда
		ТаблицаТоваров.Колонки.Добавить("МинусКоличество", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15, 3)));

		Для Каждого СтрокаТаблицы Из ТаблицаТоваров Цикл
			СтрокаТаблицы.МинусКоличество = - СтрокаТаблицы.КоличествоДок;
		КонецЦикла;
	КонецЕсли;

	Возврат ТаблицаТоваров;

КонецФункции // ПодготовитьТаблицуТоваров()

// Проверяет правильность заполнения шапки документа.
//
// Параметры:
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа.
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - заголовок сообщения об ошибках.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить.
	СтруктураОбязательныхПолей = Новый Структура("ВидОперации, Организация, Склад");

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

	Если мВидОперацииНТТ Тогда
		Если СтруктураШапкиДокумента.ВидСклада <> Перечисления.ВидыСкладов.НТТ Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Документ не может осуществлять переоценку не на НТТ!", Отказ, Заголовок);
		КонецЕсли;
	ИначеЕсли мВидОперацииРозница Тогда
		Если СтруктураШапкиДокумента.ВидСклада <> Перечисления.ВидыСкладов.Розничный Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Документ не может осуществлять переоценку не на розничном складе!", Отказ, Заголовок);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары.
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа.
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - заголовок сообщения об ошибках.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить.
	СтруктураОбязательныхПолей = Новый Структура;
	СтруктураОбязательныхПолей.Вставить("Номенклатура");
	СтруктураОбязательныхПолей.Вставить("ЦенаВРознице");

	Если мВидОперацииНТТ Тогда
		СтруктураОбязательныхПолей.Вставить("Количество");
	КонецЕсли;

	Если Не мРазрешитьНулевыеЦеныВРознице Тогда
		СтруктураОбязательныхПолей.Вставить("ЦенаВРознице");
	КонецЕсли;
	
	УправлениеЗапасами.КорректировкаСтруктурыОбязательныхПолей(СтруктураОбязательныхПолей, СтруктураШапкиДокумента.ВидСклада);

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураОбязательныхПолей, Отказ, Заголовок);

	// Здесь бланков быть не должно.
	УправлениеЗапасами.ПроверитьЧтоНетБланковСтрогогоУчета(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);
	
	Если СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийПереоценкаТоваровВРознице.ПереоценкаВНТТ Тогда
		
		// Здесь услуг быть не должно.
		УправлениеЗапасами.ПроверитьЧтоНетУслуг(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);
		
		// Здесь комплектов быть не должно.
		УправлениеЗапасами.ПроверитьЧтоНетКомплектов(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);		
	КонецЕсли;

	// Здесь наборов быть не должно.
	УправлениеЗапасами.ПроверитьЧтоНетНаборов(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);


КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры:
//  РежимПроведения         - режим проведения документа (оперативный или неоперативный).
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа.
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары.
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - заголовок сообщения об ошибках.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПереоценки, Отказ, Заголовок);

	Если мВидОперацииНТТ Тогда
		НаборДвижений = Движения.ТоварыВНТТ;

		// Контроль остатков товара
		Если Товары.Количество() <> 0 Тогда
			ПроцедурыКонтроляОстатков.ТоварыВНТТКонтрольОстатков("Товары", СтруктураШапкиДокумента, Отказ, Заголовок, РежимПроведения);
		КонецЕсли;

		// Получим таблицу значений, совпадающую со структурой набора записей регистра.
		ТаблицаДвиженийТоварыНаСкладах = НаборДвижений.Выгрузить();
		ТаблицаДвиженийТоварыНаСкладах.Очистить();
		ТаблицаДвижений = ТаблицаДвиженийТоварыНаСкладах.Скопировать();

		ТаблицаПоТоварамРасход = ТаблицаПоТоварам.Скопировать();
		ТаблицаПоТоварамРасход.Колонки.ЦенаВРозницеСтарая.Имя = "ЦенаВРознице";
		ТаблицаПоТоварамРасход.Колонки.МинусКоличество.Имя = "Количество";

		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамРасход, ТаблицаДвижений);

		ТаблицаПоТоварамПриход = ТаблицаПоТоварам.Скопировать();
		ТаблицаПоТоварамПриход.Колонки.Цена.Имя = "ЦенаВРознице";
		ТаблицаПоТоварамПриход.Колонки.КоличествоДок.Имя = "Количество";

		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварамПриход, ТаблицаДвижений);

		// Недостающие поля.
		ТаблицаДвижений.ЗаполнитьЗначения(Перечисления.ТоварТара.Товар, "ТоварТара");
		
		НаборДвижений.мПериод          = Дата;
		НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

		Если Не Отказ Тогда
			НаборДвижений.ВыполнитьПриход();
		КонецЕсли;
	ИначеЕсли мВидОперацииРозница Тогда
		НаборДвижений = Движения.ЦеныАТТ;
		ТаблицаДвижений = НаборДвижений.Выгрузить();

		// Заполним таблицу движений.
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоТоварам, ТаблицаДвижений);

		НаборДвижений.мПериод          = Дата;
		НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

		Если Не Отказ Тогда
			НаборДвижений.ВыполнитьДвижения();
		КонецЕсли;

		НаборДвижений = Движения.ТоварыВРознице;

		// Получим таблицу значений, совпадающую со структурой набора записей регистра.
		ТаблицаДвиженийТоварыНаСкладах = НаборДвижений.Выгрузить();
		ТаблицаДвиженийТоварыНаСкладах.Очистить();
		ТаблицаДвижений = ТаблицаДвиженийТоварыНаСкладах.Скопировать();

		// Заполним таблицу движений.
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПереоценки, ТаблицаДвижений);

		НаборДвижений.мПериод          = Дата;
		НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

		Если Не Отказ Тогда
			НаборДвижений.ВыполнитьПриход();
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры // ДвиженияПоРегистрам()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Обработчик события "ОбработкаПроведения".
//
Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	УстановитьФлагиВидаОперации();

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = УправлениеЗапасами.СформироватьДеревоПолейЗапросаПоШапке();
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"      , "ВалютаУправленческогоУчета"    , "ВалютаУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"      , "КурсВалютыУправленческогоУчета", "КурсВалютыУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика", "ВестиПартионныйУчетПоСкладам"  , "ВестиПартионныйУчетПоСкладам");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Склад"          , "ВидСклада"                     , "ВидСклада");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа.
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Проверим правильность заполнения шапки документа.
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);

	// Получим необходимые данные для проведения и проверки заполнения данные по табличной части "Товары".
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Номенклатура"              , "Номенклатура");
	СтруктураПолей.Вставить("КоличествоДок"             , "Количество");
	СтруктураПолей.Вставить("ХарактеристикаНоменклатуры", "ХарактеристикаНоменклатуры");
	СтруктураПолей.Вставить("СерияНоменклатуры"         , "СерияНоменклатуры");
	СтруктураПолей.Вставить("Услуга"                    , "Номенклатура.Услуга");
	СтруктураПолей.Вставить("Набор"                     , "Номенклатура.Набор");
	СтруктураПолей.Вставить("Комплект"                  , "Номенклатура.Комплект");
	СтруктураПолей.Вставить("Цена"                      , "ЦенаВРознице");
	СтруктураПолей.Вставить("ЦенаВРозницеСтарая"        , "ЦенаВРозницеСтарая");
	СтруктураПолей.Вставить("Склад"                     , "Ссылка.Склад");

	РезультатЗапросаПоТоварам = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураПолей);

	// Подготовим таблицу товаров для проведения.
	ТаблицаПоТоварам = ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента);

	ТаблицаПереоценки = ПодготовитьТаблицуПереоценки();

	// Проверить заполнение ТЧ "Товары".
	ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок);

	// Движения по документу.
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоТоварам, ТаблицаПереоценки, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ОбработкаПроведения()

// Обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	ТипОснования = ТипЗнч(Основание);
	Если ТипОснования <> Тип("ДокументСсылка.ПоступлениеТоваровУслуг")
		И ТипОснования <> Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокОснование", Основание);
	Запрос.УстановитьПараметр("ВидСкладаРозничный", Перечисления.ВидыСкладов.Розничный);

	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПоступлениеТоваровУслуг") Тогда
		ТекстЗапроса = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Док.Номенклатура КАК Номенклатура,
		|	Док.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	Док.Склад КАК Склад,
		|	1 КАК Количество,
		|	0 КАК СуммаПродажная
		|ИЗ
		|	Документ.ПоступлениеТоваровУслуг.Товары КАК Док
		|ГДЕ
		|	Док.Ссылка = &ДокОснование
		|	И Док.Склад.ВидСклада = &ВидСкладаРозничный
		|";
	ИначеЕсли ТипЗнч(Основание) = Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		ТекстЗапроса = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Док.Номенклатура КАК Номенклатура,
		|	Док.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	Док.Ссылка.СкладПолучатель КАК Склад,
		|	1 КАК Количество,
		|	0 КАК СуммаПродажная
		|ИЗ
		|	Документ.ПеремещениеТоваров.Товары КАК Док
		|ГДЕ
		|	Док.Ссылка = &ДокОснование
		|	И Док.Ссылка.СкладПолучатель.ВидСклада = &ВидСкладаРозничный
		|";
	КонецЕсли;

	Запрос.Текст = ТекстЗапроса;

	ТаблицаТоваров = Запрос.Выполнить().Выгрузить();

	ТаблицаПоЦенам = УправлениеРозничнойТорговлей.СформироватьЗапросПоПродажнымЦенам(Основание.Дата, ТаблицаТоваров.ВыгрузитьКолонку("Склад"),
	                 ТаблицаТоваров.ВыгрузитьКолонку("Номенклатура")).Выгрузить();

	УправлениеРозничнойТорговлей.ЗаполнитьКолонкуСуммаПродажная(ТаблицаТоваров, ТаблицаПоЦенам);

	ТЗТовары = ОбщегоНазначения.ОтобратьСтрокиПоКритериям(ТаблицаТоваров, Новый Структура("СуммаПродажная", 0)).Выгрузить();

	СЗ = Новый СписокЗначений;

	Для Каждого СтрокаТовара Из ТЗТовары Цикл
		Если СЗ.НайтиПоЗначению(СтрокаТовара.Склад) = Неопределено Тогда
			СЗ.Добавить(СтрокаТовара.Склад);
		КонецЕсли;
	КонецЦикла;

	Если СЗ.Количество() = 0 Тогда
		Если ТаблицаТоваров.Количество() > 0 Тогда
			Склад = ТаблицаТоваров[0].Склад;
		КонецЕсли;

		Возврат;
	ИначеЕсли СЗ.Количество() = 1 Тогда
		Склад = СЗ[0].Значение;
	Иначе
		ВыбСклад = СЗ.ВыбратьЭлемент("Выберите склад", СЗ[0]);

		Если ВыбСклад <> Неопределено Тогда
			Склад = ВыбСклад.Значение;
			ТЗТовары = ОбщегоНазначения.ОтобратьСтрокиПоКритериям(ТЗТовары, Новый Структура("Склад", Склад)).Выгрузить();
		Иначе
			Возврат;
		КонецЕсли;
	КонецЕсли;

	Дата 		= Основание.Дата;
	Организация = Основание.Организация;

	Товары.Загрузить(ТЗТовары);
	Для Каждого СтрокаТовара Из Товары Цикл
		СтрокаТовара.ЦенаВРознице = Ценообразование.ПолучитьЦенуНоменклатуры(СтрокаТовара.Номенклатура,
		   СтрокаТовара.ХарактеристикаНоменклатуры, Склад.ТипЦенРозничнойТорговли, Дата,
		   СтрокаТовара.Номенклатура.ЕдиницаХраненияОстатков, мВалютаРегламентированногоУчета, 1, 1);
	КонецЦикла;

КонецПроцедуры // ОбработкаЗаполнения()

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

   // Проверим заполненность единицы измерения и коэфициента
   Для Каждого СтрокаТовара Из Товары Цикл
		СтрокаТовара.ЕдиницаИзмерения 	= ?(НЕ ЗначениеЗаполнено(СтрокаТовара.ЕдиницаИзмерения),	СтрокаТовара.Номенклатура.ЕдиницаХраненияОстатков,	СтрокаТовара.ЕдиницаИзмерения); 
		СтрокаТовара.Коэффициент	 	= ?(НЕ ЗначениеЗаполнено(СтрокаТовара.Коэффициент),		СтрокаТовара.ЕдиницаИзмерения.Коэффициент,			СтрокаТовара.Коэффициент); 
	КонецЦикла;
	 
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");
мРазрешитьНулевыеЦеныВРознице = УправлениеДопПравамиПользователей.РазрешитьНулевыеЦеныВРознице();
