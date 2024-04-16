Перем мПериод          Экспорт; // Период движений
Перем мТаблицаДвижений Экспорт; // Таблица движений

// Выполняет приход по регистру.
//
// Параметры:
//  Нет.
//
Процедура ВыполнитьПриход() Экспорт

	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект, ВидДвиженияНакопления.Приход);

КонецПроцедуры // ВыполнитьПриход()

// Выполняет расход по регистру.
//
// Параметры:
//  Нет.
//
Процедура ВыполнитьРасход() Экспорт

	ОбщегоНазначения.ВыполнитьДвижениеПоРегистру(ЭтотОбъект, ВидДвиженияНакопления.Расход);

КонецПроцедуры // ВыполнитьРасход()

// Выполняет движения по регистру.
//
// Параметры:
//  Нет.
//
Процедура ВыполнитьДвижения() Экспорт

	Загрузить(мТаблицаДвижений);

КонецПроцедуры // ВыполнитьДвижения()

// Процедура контролирует остаток по данному регистру по переданному документу
// и его табличной части. В случае недостатка товаров выставляется флаг отказа и 
// выдается сообщегние.
//
// Параметры:
//  ДокументОбъект    - объект проводимого документа, 
//  ИмяТабличнойЧасти - строка, имя табличной части, которая проводится по регистру, 
//  СтруктураШапкиДокумента - структура, содержащая значения "через точку" ссылочных реквизитов по шапке документа,
//  Отказ             - флаг отказа в проведении,
//  Заголовок         - строка, заголовок сообщения об ошибке проведения.
//
Процедура КонтрольОстатков(ДокументОбъект, ИмяТабличнойЧасти, СтруктураШапкиДокумента, Отказ, Заголовок, РежимПроведения) Экспорт

	Если РежимПроведения <> РежимПроведенияДокумента.Оперативный
		ИЛИ УправлениеДопПравамиПользователей.РазрешеноПревышениеОстаткаТоваровОрганизации(СтруктураШапкиДокумента.Организация) Тогда
		
		Возврат;
	КонецЕсли;
	
	МетаданныеДокумента   = ДокументОбъект.Метаданные();
	ИмяДокумента          = МетаданныеДокумента.Имя;
	ИмяТаблицы            = ИмяДокумента + "." + СокрЛП(ИмяТабличнойЧасти);
	ЕстьХарактеристика    = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ХарактеристикаНоменклатуры", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьДокументПередачи  = МетаданныеДокумента.Реквизиты.Найти("ДокументПередачи") <> Неопределено;
	ЕстьСерия             = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("СерияНоменклатуры", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьКачество          = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("Качество", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьФлагУказанияСерий = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("СерияУказываетсяПриОтпускеСоСклада", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьКоэффициент       = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("Коэффициент", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьСкладВТабЧасти    = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("Склад", МетаданныеДокумента, ИмяТабличнойЧасти);
	
	СтруктураУП = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитикиУпр(СтруктураШапкиДокумента.Ссылка.Дата);
	Если НЕ ЗначениеЗаполнено(СтруктураУП) Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	КонтролироватьОстатокПоСкладу = СтруктураУП.ВестиУчетТоваровОрганизацийВРазрезеСкладов;
	
	ИмяРеквизитаСклад = "Склад";
	Если МетаданныеДокумента.Реквизиты.Найти("СкладОрдер") <> Неопределено Тогда
		ИмяРеквизитаСклад = "СкладОрдер";
	КонецЕсли;
	
	Если КонтролироватьОстатокПоСкладу Тогда
	    Если ЕстьСкладВТабЧасти Тогда
			ЗапросСклады = Новый Запрос;
			ЗапросСклады.Текст = "Выбрать различные Склад ИЗ Документ."+ИмяТаблицы+"
			|ГДЕ Ссылка=&ДокументСсылка";
			ЗапросСклады.УстановитьПараметр("ДокументСсылка",СтруктураШапкиДокумента.Ссылка);
			СписокСкладов = ЗапросСклады.Выполнить().Выгрузить().ВыгрузитьКолонку("Склад");
		Иначе
			СписокСкладов = Новый СписокЗначений;
			СписокСкладов.Добавить(СтруктураШапкиДокумента[ИмяРеквизитаСклад]);
		КонецЕсли;
	Иначе
		СписокСкладов = Новый СписокЗначений;
    КонецЕсли;
	
	// Текст вложенного запроса, ограничивающего номенклатуру при получении остатков
	ТекстЗапросаСписокНоменклатуры = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Номенклатура 
	|ИЗ
	|	Документ." + ИмяТаблицы +"
	|ГДЕ Ссылка = &ДокументСсылка";


	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка",          СтруктураШапкиДокумента.Ссылка);
	Запрос.УстановитьПараметр("Организация",             СтруктураШапкиДокумента.Организация);
	Запрос.УстановитьПараметр("ПустаяСерия"   , Справочники.СерииНоменклатуры.ПустаяСсылка());	
	Запрос.УстановитьПараметр("СписокСкладов", 	СписокСкладов);
	Если ЕстьДокументПередачи Тогда
		Запрос.УстановитьПараметр("ДокументПередачи",        СтруктураШапкиДокумента.ДокументПередачи);
	КонецЕсли;
	
	//Текст вложенного запроса для выборки полей документа
	ТекстЗапросаРеквизитыДокумента = "(
	|ВЫБРАТЬ
	|Док.Номенклатура, "+
	?(ЕстьХарактеристика, "Док.ХарактеристикаНоменклатуры, ", "")+
	?(ЕстьСерия, "Док.СерияНоменклатуры, ", "")+
	?(ЕстьКачество, "Док.Качество , ", "")+
	?(НЕ ЕстьДокументПередачи, "Док.ДокументРезерва, ", "")+
    ?(ЕстьКоэффициент, "Док.Коэффициент, ", "")+
	?(ЕстьФлагУказанияСерий, "Док.СерияУказываетсяПриОтпускеСоСклада, ", "")+ "
	|Док.Количество
	|ИЗ Документ."+ИмяТаблицы+" КАК Док
	|ГДЕ 
	|	Док.Ссылка  =  &ДокументСсылка "
	+ ?(ЕстьДокументПередачи, "", "
	|   И Док.ДокументРезерва <> Неопределено") + "
    |) КАК Док";

	Запрос.Текст = "
	|ВЫБРАТЬ // Запрос, контролирующий свободные остатки по организациям
	|	Док.Номенклатура.Представление                         КАК НоменклатураПредставление,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаХраненияОстатковПредставление,"
	+ ?(ЕстьХарактеристика, "
	|	Док.ХарактеристикаНоменклатуры				           КАК ХарактеристикаНоменклатуры,"
	,"")
	+ ?(ЕстьСерия, "
	|	Док.СерияНоменклатуры				                   КАК СерияНоменклатуры,"
	,"")
	+ ?(ЕстьКачество, "
	|	Док.Качество			                               КАК Качество,"
	,"")
	+ ?(ЕстьДокументПередачи, "
	|	&ДокументПередачи                                      КАК ДокументПередачи,", "
	|   Док.ДокументРезерва                                    КАК ДокументПередачи,")
	+?(ЕстьСкладВТабЧасти, "
	|Док.Склад                                   КАК Склад,","")
	+ ?(ЕстьКоэффициент, "
	|	СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК ДокументКоличество,", "
	|	СУММА(Док.Количество)                                  КАК ДокументКоличество,") + "
	|	ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0)       КАК ОстатокКоличество
	|ИЗ "+ТекстЗапросаРеквизитыДокумента+"
	//|	Документ." + ИмяТаблицы + " КАК Док
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки(," +
	?(КонтролироватьОстатокПоСкладу , "Склад в (&СписокСкладов) И ","") + "
	|		Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|	И Организация            = &Организация"
	+ ?(ЕстьДокументПередачи, "
	|   И ДокументПередачи = &ДокументПередачи","") + "
	|	) КАК Остатки
	|ПО 
	|	Док.Номенклатура                = Остатки.Номенклатура"
	+ ?(ЕстьХарактеристика, "
	| И Док.ХарактеристикаНоменклатуры  = Остатки.ХарактеристикаНоменклатуры"
	,"") + "
	| И "+ ?(ЕстьФлагУказанияСерий, "((Док.СерияНоменклатуры = Остатки.СерияНоменклатуры
	| И НЕ Док.СерияУказываетсяПриОтпускеСоСклада) ИЛИ (Остатки.СерияНоменклатуры = &ПустаяСерия И Док.СерияУказываетсяПриОтпускеСоСклада))", "Док.СерияНоменклатуры = Остатки.СерияНоменклатуры")
	+ ?(КонтролироватьОстатокПоСкладу И ЕстьСкладВТабЧасти, "
	| И Док.Склад = Остатки.Склад"
	,"")
	+ ?(ЕстьКачество, "
	| И Док.Качество                    = Остатки.Качество", "")
	+ ?(ЕстьДокументПередачи, "", "
	|   И ДокументПередачи = Док.ДокументРезерва") + "
	|
	|СГРУППИРОВАТЬ ПО
	|
	|	Док.Номенклатура"
	+ ?(ЕстьХарактеристика, ",
	|	Док.ХарактеристикаНоменклатуры "
	,"")
	+ ?(ЕстьДокументПередачи, "", ",
	|   Док.ДокументРезерва")
	+ ?(ЕстьСерия, ",
	|	Док.СерияНоменклатуры ", "")
	+ ?(ЕстьКачество, ",
	|	Док.Качество "	,"") +
	?(ЕстьСкладВТабЧасти, ", Док.Склад","")+"
	|
	|ИМЕЮЩИЕ ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0) < "
	+ ?(ЕстьКоэффициент, "СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент)", "СУММА(Док.Количество)") + "
	|
	|ДЛЯ ИЗМЕНЕНИЯ РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки // Блокирующие чтение таблицы остатков регистра для разрешения коллизий многопользовательской работы
	|";

	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл

		СтрокаСообщения = "Остатка " + 
		УправлениеЗапасами.ПредставлениеНоменклатуры(Выборка.НоменклатураПредставление, 
								  ?(ЕстьХарактеристика, Выборка.ХарактеристикаНоменклатуры, ""), ?(ЕстьСерия, Выборка.СерияНоменклатуры, "")) +
		" к передаче с организации " + СокрЛП(СтруктураШапкиДокумента.Организация) + ?(КонтролироватьОстатокПоСкладу," по складу "+?(ЕстьСкладВТабЧасти,Выборка.Склад,СтруктураШапкиДокумента[ИмяРеквизитаСклад]),"") + " по документу " + Выборка.ДокументПередачи +
		?(ЕстьКачество, " с качеством " + Выборка.Качество, "") + " недостаточно.";

		УправлениеЗапасами.ОшибкаНетОстатка(
			СтрокаСообщения,
			Выборка.ОстатокКоличество, 
			Выборка.ДокументКоличество,
			Выборка.ЕдиницаХраненияОстатковПредставление, 
			Отказ, 
			Заголовок);

	КонецЦикла;

КонецПроцедуры // КонтрольОстатков()

// Процедура контролирует остаток по данному регистру по переданному документу
// и его табличной части. В случае недостатка товаров выставляется флаг отказа и 
// выдается сообщегние.
//
// Параметры:
//  ДокументОбъект    - объект проводимого документа, 
//  ИмяТабличнойЧасти - строка, имя табличной части, которая проводится по регистру, 
//  СтруктураШапкиДокумента - структура, содержащая значения "через точку" ссылочных реквизитов по шапке документа,
//  Отказ             - флаг отказа в проведении,
//  Заголовок         - строка, заголовок сообщения об ошибке проведения.
//
Процедура КонтрольСвободныхОстатков(ДокументОбъект, ИмяТабличнойЧасти, СтруктураШапкиДокумента, Отказ, Заголовок, РежимПроведения) Экспорт
	 
	Если РежимПроведения <> РежимПроведенияДокумента.Оперативный
		ИЛИ УправлениеДопПравамиПользователей.РазрешеноПревышениеОстаткаТоваровОрганизации(СтруктураШапкиДокумента.Организация) Тогда
		
		Возврат;
	КонецЕсли;
	
	МетаданныеДокумента = ДокументОбъект.Метаданные();
	ИмяДокумента        = МетаданныеДокумента.Имя;
	ИмяТаблицы          = ИмяДокумента + "." + СокрЛП(ИмяТабличнойЧасти);
	ЕстьХарактеристика  = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("ХарактеристикаНоменклатуры", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьСерия           = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("СерияНоменклатуры", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьКачество        = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("Качество", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьКоэффициент     = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("Коэффициент", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьКлючСтроки      = ОбщегоНазначения.ЕстьРеквизитТабЧастиДокумента("КлючСтроки", МетаданныеДокумента, ИмяТабличнойЧасти);
	ЕстьСоставНабора    = Ложь;

	Если ЕстьКлючСтроки Тогда
		Если МетаданныеДокумента.ТабличныеЧасти.Найти("СоставНабора") <> Неопределено
		   И ДокументОбъект.СоставНабора.Количество() > 0 Тогда
			ЕстьСоставНабора = Истина;
		КонецЕсли;
	КонецЕсли;

	// Текст вложенного запроса, ограничивающего номенклатуру при получении остатков
	Если ЕстьСоставНабора Тогда
		ТекстЗапросаСписокНоменклатуры = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Док.Номенклатура КАК Номенклатура
		|ИЗ
		|	(
		|	ВЫБРАТЬ
		|		Док.Номенклатура
		|	ИЗ
		|		Документ." + ИмяТаблицы +" КАК Док
		|	ГДЕ
		|		Док.Ссылка = &ДокументСсылка
		|		И НЕ Док.Номенклатура.Комплект
		|       И НЕ Док.Номенклатура.Услуга
		|	ОБЪЕДИНИТЬ ВСЕ
		|
		|	ВЫБРАТЬ
		|		Док.Номенклатура
		|	ИЗ
		|		Документ." + ИмяДокумента + ".СоставНабора КАК Док
		|	ГДЕ
		|		Док.Ссылка = &ДокументСсылка
		|       И НЕ Док.Номенклатура.Комплект
		|		И НЕ Док.Номенклатура.Услуга
		|	) КАК Док
		|";

		ТекстЗапросаРеквизитыДокумента = "
		|	(ВЫБРАТЬ
		|			Док.Ссылка,
		|			Док.Номенклатура,
		|		" + ?(ЕстьКачество,        "Док.Качество,",                     "") + "
		|		" + ?(ЕстьХарактеристика,  "Док.ХарактеристикаНоменклатуры,",   "") + "
		|		" + ?(ЕстьСерия,           "Док.СерияНоменклатуры,",            "") + "
		|		" + ?(ЕстьКоэффициент,     "Док.Коэффициент,",                  "") + "
		|			Док.Количество
		|		ИЗ
		|			Документ." + ИмяТаблицы + " КАК Док
		|		ГДЕ
		|			Док.Ссылка = &ДокументСсылка
		|			И НЕ Док.Номенклатура.Комплект
		|           И НЕ Док.Номенклатура.Услуга
		|		ОБЪЕДИНИТЬ ВСЕ
		|
		|		ВЫБРАТЬ
		|			Док.Ссылка,
		|			Док.Номенклатура,
		|		" + ?(ЕстьКачество,        "Док.Качество,",                     "") + "
		|		" + ?(ЕстьХарактеристика,  "Док.ХарактеристикаНоменклатуры,",   "") + "
		|		" + ?(ЕстьСерия,           "Док.СерияНоменклатуры,",            "") + "
		|		" + ?(ЕстьКоэффициент,     "Док.Коэффициент,",                  "") + "
		|			Док.Количество
		|		ИЗ
		|			(ВЫБРАТЬ
		|				ДокНаб.Ссылка,
		|				ДокНаб.Номенклатура,
		|";
		Если ЕстьКачество Тогда
		ТекстЗапросаРеквизитыДокумента = ТекстЗапросаРеквизитыДокумента + "
		|				ВЫБОР
		|					КОГДА ДокНаб.Качество = &ПустоеКачество ТОГДА ДокТов.Качество
		|					ИНАЧЕ ДокНаб.Качество
		|				КОНЕЦ КАК Качество,
		|";
		КонецЕсли;
		ТекстЗапросаРеквизитыДокумента = ТекстЗапросаРеквизитыДокумента + "
		|			" + ?(ЕстьХарактеристика,  "ДокНаб.ХарактеристикаНоменклатуры,",                   "") + "
		|			" + ?(ЕстьСерия,           "ДокНаб.СерияНоменклатуры,",                            "") + "
		|			" + ?(ЕстьКоэффициент,     "ДокНаб.ЕдиницаИзмерения.Коэффициент КАК Коэффициент,", "") + "
		|				ДокНаб.Количество * ДокТов.Количество КАК Количество
		|			ИЗ
		|				Документ." + ИмяДокумента + ".СоставНабора   КАК ДокНаб
		|				ЛЕВОЕ СОЕДИНЕНИЕ Документ." + ИмяТаблицы + " КАК ДокТов
		|					ПО ДокТов.КлючСтроки = ДокНаб.КлючСтроки
		|					 И ДокТов.Ссылка     = &ДокументСсылка
		|			ГДЕ
		|				ДокНаб.Ссылка = &ДокументСсылка
		|               И НЕ ДокНаб.Номенклатура.Комплект
		|				И НЕ ДокНаб.Номенклатура.Услуга
		|			) КАК Док
		|
		|		) КАК Док
		|";
	Иначе
		ТекстЗапросаСписокНоменклатуры = "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Номенклатура 
		|ИЗ
		|	Документ." + ИмяТаблицы +"
		|ГДЕ  Ссылка = &ДокументСсылка
		|       И НЕ Номенклатура.Комплект
		|		И НЕ Номенклатура.Услуга
		|";

		ТекстЗапросаРеквизитыДокумента = "(
		|ВЫБРАТЬ
		|Док.Номенклатура, "+
		?(ЕстьСерия, "Док.СерияНоменклатуры, ","")+
		?(ЕстьХарактеристика, "Док.ХарактеристикаНоменклатуры, ","")+
		?(ЕстьКачество, "Док.Качество, ","")+
		?(ЕстьКоэффициент, "Док.Коэффициент, ","")+"
		|Док.Количество
		|ИЗ
		|	Документ." + ИмяТаблицы + " КАК Док
		|	ГДЕ Ссылка = &ДокументСсылка
		|       И НЕ Док.Номенклатура.Комплект
		|		И НЕ Док.Номенклатура.Услуга
		|) КАК Док";
	КонецЕсли;

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка", СтруктураШапкиДокумента.Ссылка);
	Запрос.УстановитьПараметр("Организация"   , СтруктураШапкиДокумента.Организация);
	Запрос.УстановитьПараметр("ПустаяСерия"   , Справочники.СерииНоменклатуры.ПустаяСсылка());
	Запрос.УстановитьПараметр("ПустоеКачество", Справочники.Качество.ПустаяСсылка());

	Запрос.Текст = "
	|ВЫБРАТЬ // Запрос, контролирующий по организациям
	|	Док.Номенклатура.Представление                         КАК НоменклатураПредставление,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаХраненияОстатковПредставление,
	|	""""                                                   КАК СерияНоменклатуры,"
	+ ?(ЕстьХарактеристика, "
	|	Док.ХарактеристикаНоменклатуры				           КАК ХарактеристикаНоменклатуры,"
	,"")
	+ ?(ЕстьКачество, "
	|	Док.Качество			                               КАК Качество,"
	,"")
	+ ?(ЕстьКоэффициент, "
	|	СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК ДокументКоличество,", "
	|	СУММА(Док.Количество)                                  КАК ДокументКоличество,") + "
	|	ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0)                    КАК ОстаткиКоличество,
	|	ЕСТЬNULL(МАКСИМУМ(КПередаче.КоличествоОстаток), 0)                  КАК КПередачеКоличество
	|ИЗ 
	|	"+ ТекстЗапросаРеквизитыДокумента + "
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыОрганизаций.Остатки(,
	|		Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|		И Организация = &Организация) КАК Остатки
	|ПО 
	|	Док.Номенклатура                = Остатки.Номенклатура "
	+ ?(ЕстьХарактеристика, "
	| И Док.ХарактеристикаНоменклатуры  = Остатки.ХарактеристикаНоменклатуры"
	,"")
	+ ?(ЕстьКачество, "
	| И Док.Качество                    = Остатки.Качество", "") + "
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки(,
	|		Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|		И Организация = &Организация) КАК КПередаче
	|ПО 
	|	Док.Номенклатура                = КПередаче.Номенклатура "
	+ ?(ЕстьХарактеристика, "
	| И Док.ХарактеристикаНоменклатуры  = КПередаче.ХарактеристикаНоменклатуры", "")
	+ ?(ЕстьКачество, "
	| И Док.Качество                    = КПередаче.Качество", "") + "
	|
	|СГРУППИРОВАТЬ ПО
	|
	|	Док.Номенклатура"
	+ ?(ЕстьХарактеристика, ",
	|	Док.ХарактеристикаНоменклатуры ", "")
	+ ?(ЕстьКачество, ",
	|	Док.Качество "
	,"") + "
	|
	|ИМЕЮЩИЕ ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0) - ЕСТЬNULL(МАКСИМУМ(КПередаче.КоличествоОстаток), 0) < "
	+ ?(ЕстьКоэффициент, "СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент)", "СУММА(Док.Количество)") + "
	|
	|ДЛЯ ИЗМЕНЕНИЯ РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки // Блокирующие чтение таблицы остатков регистра для разрешения коллизий многопользовательской работы
	|"
	+ ?(ЕстьСерия, "
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ // Запрос, контролирующий по организациям
	|	Док.Номенклатура.Представление                         КАК НоменклатураПредставление,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаХраненияОстатковПредставление,
	|	Док.СерияНоменклатуры			                       КАК СерияНоменклатуры,"
	+ ?(ЕстьХарактеристика, "
	|	Док.ХарактеристикаНоменклатуры				           КАК ХарактеристикаНоменклатуры,"
	,"")
	+ ?(ЕстьКачество, "
	|	Док.Качество			                               КАК Качество,"
	,"") + "
	|	СУММА(Док.Количество)                                  КАК ДокументКоличество,
	|	ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0)       КАК ОстаткиКоличество,
	|	ЕСТЬNULL(МАКСИМУМ(КПередаче.КоличествоОстаток), 0)     КАК КПередачеКоличество
	|ИЗ 
	|	"+ ТекстЗапросаРеквизитыДокумента + "
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыОрганизаций.Остатки(,
	|		Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|		И Организация = &Организация) КАК Остатки
	|ПО 
	|	Док.Номенклатура                = Остатки.Номенклатура
	|	И Док.СерияНоменклатуры           = Остатки.СерияНоменклатуры "
	+ ?(ЕстьХарактеристика, "
	| И Док.ХарактеристикаНоменклатуры  = Остатки.ХарактеристикаНоменклатуры"
	,"")
	+ ?(ЕстьКачество, "
	| И Док.Качество                    = Остатки.Качество", "") + "
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки(,
	|		Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|		И Организация = &Организация) КАК КПередаче
	|ПО 
	|	Док.Номенклатура                = КПередаче.Номенклатура 
	|	И Док.СерияНоменклатуры         = КПередаче.СерияНоменклатуры "
	+ ?(ЕстьХарактеристика, "
	| И Док.ХарактеристикаНоменклатуры  = КПередаче.ХарактеристикаНоменклатуры", "")
	+ ?(ЕстьКачество, "
	| И Док.Качество                    = КПередаче.Качество", "") + "
	|
	|ГДЕ
	|   Док.СерияНоменклатуры <> &ПустаяСерия
	|СГРУППИРОВАТЬ ПО
	|
	|	Док.Номенклатура,
	|	Док.СерияНоменклатуры"
	+ ?(ЕстьХарактеристика, ",
	|	Док.ХарактеристикаНоменклатуры ", "")
	+ ?(ЕстьКачество, ",
	|	Док.Качество "
	,"") + "
	|
	|ИМЕЮЩИЕ ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0) - ЕСТЬNULL(МАКСИМУМ(КПередаче.КоличествоОстаток), 0) < СУММА(Док.Количество)
	|	
	|ДЛЯ ИЗМЕНЕНИЯ РегистрНакопления.ТоварыКПередачеОрганизаций.Остатки // Блокирующие чтение таблицы остатков регистра для разрешения коллизий многопользовательской работы
	|"
	,"");
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл

		СвободныйОстаток           = Выборка.ОстаткиКоличество - Выборка.КПередачеКоличество;
			
		СтрокаСообщения = "Свободного остатка для резервирования " + 
		УправлениеЗапасами.ПредставлениеНоменклатуры(Выборка.НоменклатураПредставление, 
								  ?(ЕстьХарактеристика, Выборка.ХарактеристикаНоменклатуры, ""), ?(ЕстьСерия, Выборка.СерияНоменклатуры, "")) +
		" по организации """ + ?(ЕстьКачество, СокрЛП(СтруктураШапкиДокумента.Организация) + """ с качеством " + Выборка.Качество, "") + " недостаточно.";

		УправлениеЗапасами.ОшибкаНетОстатка(
			СтрокаСообщения, 
			СвободныйОстаток, 
			Выборка.ДокументКоличество,
			Выборка.ЕдиницаХраненияОстатковПредставление, 
			Отказ, 
			Заголовок);
			
		Если Выборка.КПередачеКоличество<>0 Тогда
			Сообщить("Зарезервировано под выписанные документы: " + Выборка.КПередачеКоличество);
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры // КонтрольСвободныхОстатков()

