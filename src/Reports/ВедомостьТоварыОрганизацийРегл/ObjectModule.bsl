#Если Клиент Тогда
	
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ НАЧАЛЬНОЙ НАСТРОЙКИ ОТЧЕТА

// Процедура установки начальных настроек отчета по метаданным регистра накопления
//
Процедура УстановитьНачальныеНастройки(ДополнительныеПараметры = Неопределено) Экспорт
	
	// Настройка общих параметров универсального отчета
	
	// Содержит название отчета, которое будет выводиться в шапке.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.мНазваниеОтчета = "Название отчета";
	УниверсальныйОтчет.мНазваниеОтчета = СокрЛП(ЭтотОбъект.Метаданные().Синоним);
	
	// Содержит признак необходимости отображения надписи и поля выбора раздела учета в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	УниверсальныйОтчет.мВыбиратьИмяРегистра = Ложь;
	
	// Содержит имя регистра, по метаданным которого будет выполняться заполнение настроек отчета.
	// Тип: Строка.
	// Пример:
	// УниверсальныйОтчет.ИмяРегистра = "ТоварыНаСкладах";
	УниверсальныйОтчет.ИмяРегистра = "ТоварыОрганизацийРегл";
	
	// Содержит признак необходимости вывода отрицательных значений показателей красным цветом.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ОтрицательноеКрасным = Истина;
	
	// Содержит признак необходимости вывода в отчет общих итогов.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.ВыводитьОбщиеИтоги = Ложь;
	
	// Содержит признак необходимости вывода детальных записей в отчет.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ВыводитьДетальныеЗаписи = Истина;
	
	// Содержит признак необходимости отображения флага использования свойств и категорий в форме настройки.
	// Тип: Булево.
	// Значение по умолчанию: Истина.
	// Пример:
	// УниверсальныйОтчет.мВыбиратьИспользованиеСвойств = Ложь;
	
	// Содержит признак использования свойств и категорий при заполнении настроек отчета.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.ИспользоватьСвойстваИКатегории = Истина;
	
	// Содержит признак использования простой формы настроек отчета без группировок колонок.
	// Тип: Булево.
	// Значение по умолчанию: Ложь.
	// Пример:
	// УниверсальныйОтчет.мРежимФормыНастройкиБезГруппировокКолонок = Истина;
	
	// Дополнительные параметры, переданные из отчета, вызвавшего расшифровку.
	// Информация, передаваемая в переменной ДополнительныеПараметры, может быть использована
	// для реализации специфичных для данного отчета параметрических настроек.
	
	УниверсальныйОтчет.ДобавитьПолеГруппировка("БазоваяЕдиницаИзмерения", "Номенклатура",      "БазоваяЕдиницаИзмерения", "Базовая единица измерения");
	УниверсальныйОтчет.ДобавитьПолеГруппировка("ЕдиницаХраненияОстатков", "Номенклатура",      "ЕдиницаХраненияОстатков", "Единица хранения остатков");
	
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовНачальныйОстаток", "ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (нач. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовПриход",           "ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (приход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовРасход",           "ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (расход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовКонечныйОстаток",  "ИсточникДанных.КоличествоКонечныйОстаток  * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (кон. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоЕдиницОтчетовОборот",           "ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент / Номенклатура.ЕдиницаДляОтчетов.Коэффициент", "Количество (в ед. отчетов) (оборот)");
	
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдНачальныйОстаток",     "ИсточникДанных.КоличествоНачальныйОстаток * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (нач. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдПриход",               "ИсточникДанных.КоличествоПриход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (приход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдРасход",               "ИсточникДанных.КоличествоРасход * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (расход)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдКонечныйОстаток",      "ИсточникДанных.КоличествоКонечныйОстаток  * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (кон. ост.)");
	УниверсальныйОтчет.ДобавитьПолеРесурс("КоличествоБазовыхЕдОборот",               "ИсточникДанных.КоличествоОборот * ИсточникДанных.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент", "Количество (в базовых единицах) (оборот)");
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдНачальныйОстаток", "Начальный остаток", Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдПриход",           "Приход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдРасход",           "Расход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдКонечныйОстаток",  "Конечный остаток",  Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоБазовыхЕдОборот",           "Оборот",            Ложь, "ЧЦ=15; ЧДЦ=3", "КолБазовыхЕд", "Количество (в базовых единицах)");
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовНачальныйОстаток", "Начальный остаток", Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовПриход",           "Приход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовРасход",           "Расход",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовКонечныйОстаток",  "Конечный остаток",  Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоЕдиницОтчетовОборот",           "Оборот",            Ложь, "ЧЦ=15; ЧДЦ=3", "КоличествоЕдиницОтчетов", "Количество (в ед. отчетов)");
	
	// Заполнение начальных настроек универсального отчета
	УниверсальныйОтчет.УстановитьНачальныеНастройки(Истина);
	
	УниверсальныйОтчет.ДобавитьПоказатель("КоличествоОборот",, Ложь,, "Количество");
	
	// Добавление предопределенных группировок строк отчета.
	// Необходимо вызывать для каждой добавляемой группировки строки.
	// УниверсальныйОтчет.ДобавитьИзмерениеСтроки(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Организация");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("Номенклатура");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("СчетУчетаБУ");
	УниверсальныйОтчет.ДобавитьИзмерениеСтроки("НалоговоеНазначение");
	
	// Добавление предопределенных группировок колонок отчета.
	// Необходимо вызывать для каждой добавляемой группировки колонки.
	// УниверсальныйОтчет.ДобавитьИзмерениеКолонки(<ПутьКДанным>);
	
	// Добавление предопределенных отборов отчета.
	// Необходимо вызывать для каждого добавляемого отбора.
	// УниверсальныйОтчет.ДобавитьОтбор(<ПутьКДанным>);
	УниверсальныйОтчет.ДобавитьОтбор("Организация");
	УниверсальныйОтчет.ДобавитьОтбор("Номенклатура");
	
	// Добавление предопределенных полей порядка отчета.
	// Необходимо вызывать для каждого добавляемого поля порядка.
	// УниверсальныйОтчет.ДобавитьПорядок(<ПутьКДанным>);
	
	// Установка связи подчиненных и родительских полей
	// УниверсальныйОтчет.УстановитьСвязьПолей(<ПутьКДанным>, <ПутьКДаннымРодитель>);
	
	// Установка связи полей и измерений
	// УниверсальныйОтчет.УстановитьСвязьПоляИИзмерения(<ИмяПоля>, <ИмяИзмерения>);
	
	// Добавление дополнительных полей
	// Необходимо вызывать для каждого добавляемого дополнительного поля.
	// УниверсальныйОтчет.ДобавитьДополнительноеПоле(<ПутьКДанным>, <Размещение>, <Положение>);
	УниверсальныйОтчет.ДобавитьДополнительноеПоле("ЕдиницаХраненияОстатков");
	
КонецПроцедуры // УстановитьНачальныеНастройки()

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ФОРМИРОВАНИЯ ОТЧЕТА 
	
// Процедура формирования отчета
//
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт
	
	// Перед формирование отчета можно установить необходимые параметры универсального отчета.
	
	УниверсальныйОтчет.СформироватьОтчет(ТабличныйДокумент,,, ЭтотОбъект);

КонецПроцедуры // СформироватьОтчет()

Функция ПолучитьТекстСправкиФормы() Экспорт
	
	Возврат "";
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Процедура обработки расшифровки
//
Процедура ОбработкаРасшифровки(Расшифровка, Объект) Экспорт
	
	// Дополнительные параметры в расшифровывающий отчет можно передать
	// посредством инициализации переменной "ДополнительныеПараметры".
	
	ДополнительныеПараметры = Неопределено;
	УниверсальныйОтчет.ОбработкаРасшифровкиУниверсальногоОтчета(Расшифровка, Объект, ДополнительныеПараметры);
	
КонецПроцедуры // ОбработкаРасшифровки()

// Формирует структуру для сохранения настроек отчета
//
Процедура СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками) Экспорт
	
	УниверсальныйОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураСНастройками);
	
КонецПроцедуры // СформироватьСтруктуруДляСохраненияНастроек()

// Заполняет настройки отчета из структуры сохраненных настроек
//
Функция ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт
	
	Возврат УниверсальныйОтчет.ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ЭтотОбъект);
	
КонецФункции // ВосстановитьНастройкиИзСтруктуры()

// Содержит значение используемого режима ввода периода.
// Тип: Число.
// Возможные значения: 0 - произвольный период, 1 - на дату, 2 - неделя, 3 - декада, 4 - месяц, 5 - квартал, 6 - полугодие, 7 - год
// Значение по умолчанию: 0
// Пример:
// УниверсальныйОтчет.мРежимВводаПериода = 1;

#КонецЕсли