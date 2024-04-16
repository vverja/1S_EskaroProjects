Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;

//Процедура заполнения выполняемых действий при создании нового документа
Процедура ЗаполнитьВыполняемыеДействия() Экспорт
	ДенежныеСредстваВКассах            = ОтражатьВУправленческомУчете;
	ДенежныеСредстваНаБанковскихСчетах = ОтражатьВУправленческомУчете;
	ДенежныеСредстваВПути			   = ОтражатьВУправленческомУчете;
	ВзаиморасчетыСКонтрагентами        = ОтражатьВУправленческомУчете;
	ВзаиморасчетыСПодотчетнымиЛицами   = ОтражатьВУправленческомУчете;

	Если ОтражатьВУправленческомУчете Тогда
		ОтражатьВБухгалтерскомУчете = Ложь;
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
	
// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
// Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
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

	Если ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	Если СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете Тогда

		СтруктураОбязательныхПолей = Новый Структура("Организация, Дата");

		// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский)
		ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);

		// Теперь вызовем общую процедуру проверки.
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Формирует таблицу данных с итогами по подотчетникам
//
Функция ПодготовитьТаблицуПоПодотчетникам(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецДня(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = "
	|ВЫБРАТЬ 
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.Организация,
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.ФизЛицо,
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.РасчетныйДокумент,
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.СуммаВзаиморасчетовОстаток  КАК СуммаВзаиморасчетовОстаток,
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.СуммаУпрОстаток             КАК СуммаУпрОстаток,
	|	ВзаиморасчетыСПодотчетнымиЛицамиОстатки.Валюта                      КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс                                        КАК КурсВалютыДенежныхСредств, 
	|	КурсыВалютСрезПоследних.Кратность                                   КАК КратностьВалютыДенежныхСредств 
	|ИЗ
	|	РегистрНакопления.ВзаиморасчетыСПодотчетнымиЛицами.Остатки(&ГраницаОстатков,) КАК ВзаиморасчетыСПодотчетнымиЛицамиОстатки
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков,) КАК КурсыВалютСрезПоследних
	|ПО
	|	КурсыВалютСрезПоследних.Валюта = ВзаиморасчетыСПодотчетнымиЛицамиОстатки.Валюта";
	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;
	
	Для каждого СтрокаТаблицы из Выборка Цикл
		
		Если Не СтрокаТаблицы.КурсВалютыДенежныхСредств=NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаВзаиморасчетовОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
																								
													
		КонецЕсли;
												
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
		
	КонецЦикла;
	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;

	Возврат Выборка;

КонецФункции

// Формирует таблицу данных с итогами по взаиморасчетам
//
Функция ПодготовитьТаблицуПоВзаиморасчетам(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецДня(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента,
	|	ВзаиморасчетысКонтрагентамиОстатки.Контрагент,
	|	ВзаиморасчетысКонтрагентамиОстатки.Организация,
	|	ВзаиморасчетысКонтрагентамиОстатки.Сделка,
	|	ВзаиморасчетысКонтрагентамиОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВзаиморасчетовОстаток,
	|	ВзаиморасчетысКонтрагентамиОстатки.СуммаУпрОстаток КАК СуммаУпрОстаток,
	|	ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс КАК КурсВалютыДенежныхСредств,
	|	КурсыВалютСрезПоследних.Кратность КАК КратностьВалютыДенежныхСредств
	|ИЗ
	|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.Остатки(&ГраницаОстатков, ) КАК ВзаиморасчетысКонтрагентамиОстатки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков, ) КАК КурсыВалютСрезПоследних
	|		ПО КурсыВалютСрезПоследних.Валюта = ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов";

	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;
	
	Для каждого СтрокаТаблицы из Выборка Цикл
		
		Если Не СтрокаТаблицы.КурсВалютыДенежныхСредств=NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаВзаиморасчетовОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
																								
													
		КонецЕсли;
												
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
		
	КонецЦикла;
	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;

	Возврат Выборка;

КонецФункции

// Формирует таблицу данных с итогами по расчетам
//
Функция ПодготовитьТаблицуПоРасчетам(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецДня(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента,
	|	ВзаиморасчетысКонтрагентамиОстатки.Контрагент,
	|	ВзаиморасчетысКонтрагентамиОстатки.Организация,
	|	ВзаиморасчетысКонтрагентамиОстатки.Сделка,
	|	ВзаиморасчетысКонтрагентамиОстатки.РасчетыВозврат,
	|	ВзаиморасчетысКонтрагентамиОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВзаиморасчетовОстаток,
	|	ВзаиморасчетысКонтрагентамиОстатки.СуммаУпрОстаток            КАК СуммаУпрОстаток,
	|	ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс                                  КАК КурсВалютыДенежныхСредств, 
	|	КурсыВалютСрезПоследних.Кратность                             КАК КратностьВалютыДенежныхСредств 
	|ИЗ
	|	РегистрНакопления.РасчетысКонтрагентами.Остатки(&ГраницаОстатков,) КАК ВзаиморасчетысКонтрагентамиОстатки
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков,) КАК КурсыВалютСрезПоследних
	|ПО
	|	КурсыВалютСрезПоследних.Валюта = ВзаиморасчетысКонтрагентамиОстатки.ДоговорКонтрагента.ВалютаВзаиморасчетов";
	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;
	
	Для каждого СтрокаТаблицы из Выборка Цикл
		
		Если Не СтрокаТаблицы.КурсВалютыДенежныхСредств=NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаВзаиморасчетовОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
																								
													
		КонецЕсли;
												
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
		
	КонецЦикла;
	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;

	Возврат Выборка;

КонецФункции

// Формирует таблицу данных с итогами по денежным средствам
//
Функция ПодготовитьТаблицуПоДенежнымСредствам(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецДня(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДенежныеСредстваОстатки.БанковскийСчетКасса,
	|	ДенежныеСредстваОстатки.Организация,
	|	ДенежныеСредстваОстатки.ВидДенежныхСредств,
	|	ДенежныеСредстваОстатки.СуммаОстаток    КАК СуммаОстаток,
	|	ДенежныеСредстваОстатки.СуммаУпрОстаток КАК СуммаУпрОстаток,
	|	ДенежныеСредстваОстатки.БанковскийСчетКасса.ВалютаДенежныхСредств КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс            КАК КурсВалютыДенежныхСредств, 
	|	КурсыВалютСрезПоследних.Кратность       КАК КратностьВалютыДенежныхСредств 
	|ИЗ
	|	РегистрНакопления.ДенежныеСредства.Остатки(&ГраницаОстатков,) КАК ДенежныеСредстваОстатки
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков,) КАК КурсыВалютСрезПоследних
	|ПО
	|	КурсыВалютСрезПоследних.Валюта = ДенежныеСредстваОстатки.БанковскийСчетКасса.ВалютаДенежныхСредств";

	Если НЕ ДенежныеСредстваВКассах Тогда

		ЗапросПоДенежнымСредствам.Текст = ЗапросПоДенежнымСредствам.Текст + "
		|ГДЕ
		|	ДенежныеСредстваОстатки.БанковскийСчетКасса ССЫЛКА Справочник.БанковскиеСчета";

	ИначеЕсли НЕ ДенежныеСредстваНаБанковскихСчетах Тогда

		ЗапросПоДенежнымСредствам.Текст = ЗапросПоДенежнымСредствам.Текст + "
		|ГДЕ
		|	ДенежныеСредстваОстатки.БанковскийСчетКасса ССЫЛКА Справочник.Кассы";

	КонецЕсли;

	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;
	
	Для каждого СтрокаТаблицы из Выборка Цикл
		
		Если Не СтрокаТаблицы.КурсВалютыДенежныхСредств=NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
																								
													
		КонецЕсли;
												
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
		
	КонецЦикла;
	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;

	Возврат Выборка;

КонецФункции

// Формирует таблицу данных с итогами по денежным средствам
//
Функция ПодготовитьТаблицуПоДенежнымСредствамКПолучению(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецДня(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДенежныеСредстваКПолучениюОстатки.Организация,
	|	ДенежныеСредстваКПолучениюОстатки.БанковскийСчетКасса,
	|	ДенежныеСредстваКПолучениюОстатки.ВидДенежныхСредств,
	|	ДенежныеСредстваКПолучениюОстатки.ДокументПолучения,
	|	ДенежныеСредстваКПолучениюОстатки.СуммаОстаток    КАК СуммаОстаток,
	|	ДенежныеСредстваКПолучениюОстатки.СуммаУпрОстаток КАК СуммаУпрОстаток,
	|	ДенежныеСредстваКПолучениюОстатки.БанковскийСчетКасса.ВалютаДенежныхСредств КАК Валюта,
	|	КурсыВалютСрезПоследних.Курс            КАК КурсВалютыДенежныхСредств, 
	|	КурсыВалютСрезПоследних.Кратность       КАК КратностьВалютыДенежныхСредств 
	|ИЗ
	|	РегистрНакопления.ДенежныеСредстваКПолучению.Остатки(&ГраницаОстатков,) КАК ДенежныеСредстваКПолучениюОстатки
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков,) КАК КурсыВалютСрезПоследних
	|ПО
	|	КурсыВалютСрезПоследних.Валюта = ДенежныеСредстваКПолучениюОстатки.БанковскийСчетКасса.ВалютаДенежныхСредств";

	Если НЕ ДенежныеСредстваВКассах Тогда

		ЗапросПоДенежнымСредствам.Текст = ЗапросПоДенежнымСредствам.Текст + "
		|ГДЕ
		|	ДенежныеСредстваКПолучениюОстатки.БанковскийСчетКасса ССЫЛКА Справочник.БанковскиеСчета";

	ИначеЕсли НЕ ДенежныеСредстваНаБанковскихСчетах Тогда

		ЗапросПоДенежнымСредствам.Текст = ЗапросПоДенежнымСредствам.Текст + "
		|ГДЕ
		|	ДенежныеСредстваКПолучениюОстатки.БанковскийСчетКасса ССЫЛКА Справочник.Кассы";

	КонецЕсли;

	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;
	
	Для каждого СтрокаТаблицы из Выборка Цикл
		
		Если Не СтрокаТаблицы.КурсВалютыДенежныхСредств=NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалютыДенежныхСредств, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
																								
													
		КонецЕсли;
												
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
		
	КонецЦикла;
	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;

	Возврат Выборка;

КонецФункции

// Формирует таблицу данных с итогами по денежным средствам в пути
//
Функция ПодготовитьТаблицуПоДенежнымСредствамВПути(СтруктураШапкиДокумента)

	ЗапросПоДенежнымСредствам = Новый Запрос;
	ЗапросПоДенежнымСредствам.УстановитьПараметр("ГраницаОстатков", Новый Граница(КонецМесяца(Дата), ВидГраницы.Включая));
	ЗапросПоДенежнымСредствам.Текст = "
	|ВЫБРАТЬ
	|	ДенежныеСредстваВПутиОстатки.Банк,
	|	ДенежныеСредстваВПутиОстатки.Валюта,
	|	ДенежныеСредстваВПутиОстатки.СуммаОстаток,
	|	ДенежныеСредстваВПутиОстатки.СуммаУпрОстаток,
	|	КурсыВалютСрезПоследних.Курс            КАК КурсВалюты, 
	|	КурсыВалютСрезПоследних.Кратность       КАК КратностьВалюты 
	|ИЗ
	|	РегистрНакопления.ДенежныеСредстваВПути.Остатки(&ГраницаОстатков,)   КАК ДенежныеСредстваВПутиОстатки
	|ЛЕВОЕ СОЕДИНЕНИЕ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ГраницаОстатков,) КАК КурсыВалютСрезПоследних
	|ПО
	|	КурсыВалютСрезПоследних.Валюта = ДенежныеСредстваВПутиОстатки.Валюта";

	Выборка = ЗапросПоДенежнымСредствам.Выполнить().Выгрузить();

	Выборка.Колонки.Добавить("СуммаУпр",Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
    МассивДляУдаления=Новый Массив;

	Для каждого СтрокаТаблицы из Выборка Цикл

		Если Не СтрокаТаблицы.КурсВалюты = NULL Тогда 
		
		СтрокаТаблицы.СуммаУпр = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.СуммаОстаток, СтрокаТаблицы.Валюта,
													СтруктураШапкиДокумента.ВалютаУправленческогоУчета, 
													СтрокаТаблицы.КурсВалюты, 
													СтруктураШапкиДокумента.КурсВалютыУправленческогоУчета,
													СтрокаТаблицы.КратностьВалюты, 
													СтруктураШапкиДокумента.КратностьВалютыУправленческогоУчета) - 
													СтрокаТаблицы.СуммаУпрОстаток;
        КонецЕсли;
		
		Если СтрокаТаблицы.СуммаУпр=0 Тогда
			МассивДляУдаления.Добавить(СтрокаТаблицы);
		КонецЕсли;		
													
	КонецЦикла;

	
	Для Каждого Строка ИЗ МассивДляУдаления Цикл
		Выборка.Удалить(Строка);
	КонецЦикла;
	
	Возврат Выборка;

КонецФункции

Процедура ДвиженияПорегистрамВзаиморасчетыСПодотчетнымиЛицамиУпр(РежимПроведения, СтруктураШапкиДокумента, 
			ТаблицаПоПодотчетникам, Отказ, Заголовок)

	Если НЕ СтруктураШапкиДокумента.ВзаиморасчетыСПодотчетнымиЛицами Тогда
		Возврат;
	КонецЕсли;

	НаборДвижений   = Движения.ВзаиморасчетыСПодотчетнымиЛицами;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоПодотчетникам, ТаблицаДвижений);

	НаборДвижений.мПериод          = КонецМесяца(Дата);
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ВзаиморасчетыСПодотчетнымиЛицами.ВыполнитьПриход();
	КонецЕсли;

КонецПроцедуры // ДвиженияПорегистрамВзаиморасчетыСПодотчетнымиЛицамиУпр()

Процедура ДвиженияПорегистрамВзаиморасчетыСКонтрагентамиУпр(РежимПроведения, СтруктураШапкиДокумента, 
			ТаблицаПоВзаиморасчетам,ТаблицаПоРасчетам, Отказ, Заголовок)

	Если НЕ СтруктураШапкиДокумента.ВзаиморасчетыСКонтрагентами Тогда
		Возврат;
	КонецЕсли;

	НаборДвижений = Движения.ВзаиморасчетыСКонтрагентами;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоВзаиморасчетам, ТаблицаДвижений);

	НаборДвижений.мПериод          = КонецМесяца(Дата);
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ВзаиморасчетыСКонтрагентами.ВыполнитьПриход();
	КонецЕсли;

	НаборДвижений = Движения.РасчетыСКонтрагентами;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоРасчетам, ТаблицаДвижений);

	НаборДвижений.мПериод          = КонецМесяца(Дата);
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.РасчетыСКонтрагентами.ВыполнитьПриход();
	КонецЕсли;

КонецПроцедуры // ДвиженияПорегистрамВзаиморасчетыСПодотчетнымиЛицамиУпр()

// Формирует движения по денежным средствам
//
Процедура ДвиженияПорегистрамДенежныеСредстваУпр(РежимПроведения, СтруктураШапкиДокумента, 
			ТаблицаПоДенежнымСредствам,ТаблицаПоДенежнымСредствамКПолучению, ТаблицаПоДенежнымСредствамВПути, Отказ, Заголовок)

	Если СтруктураШапкиДокумента.ДенежныеСредстваВПути Тогда
		
		НаборДвижений = Движения.ДенежныеСредстваВПути;

		// Получим таблицу значений, совпадающую со структурой набора записей регистра.
		ТаблицаДвижений = НаборДвижений.Выгрузить();

		// Заполним таблицу движений.
		ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоДенежнымСредствамВПути, ТаблицаДвижений);

		НаборДвижений.мПериод = КонецМесяца(Дата);
		НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

		Если Не Отказ Тогда
			Движения.ДенежныеСредстваВПути.ВыполнитьПриход();
		КонецЕсли;
		
	КонецЕсли;	
			
	Если НЕ (СтруктураШапкиДокумента.ДенежныеСредстваВКассах ИЛИ СтруктураШапкиДокумента.ДенежныеСредстваНаБанковскихСчетах) Тогда
		Возврат;
	КонецЕсли;

	НаборДвижений = Движения.ДенежныеСредства;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоДенежнымСредствам, ТаблицаДвижений);

	НаборДвижений.мПериод          = КонецМесяца(Дата);
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ДенежныеСредства.ВыполнитьПриход();
	КонецЕсли;

	НаборДвижений = Движения.ДенежныеСредстваКПолучению;

	// Получим таблицу значений, совпадающую со структурой набора записей регистра.
	ТаблицаДвижений = НаборДвижений.Выгрузить();

	// Заполним таблицу движений.
	ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаПоДенежнымСредствамКПолучению, ТаблицаДвижений);

	НаборДвижений.мПериод          = КонецМесяца(Дата);
	НаборДвижений.мТаблицаДвижений = ТаблицаДвижений;

	Если Не Отказ Тогда
		Движения.ДенежныеСредстваКПолучению.ВыполнитьПриход();
	КонецЕсли;

КонецПроцедуры // ДвиженияПорегистрамДенежныеСредстваУпр()

// Формирует движения по регистрам бухгалтерии
//
Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, Отказ, Заголовок)

	Запрос = Новый Запрос;
	
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	Хозрасчетный.Ссылка КАК СчетПереоценки
	|ИЗ
	|	ПланСчетов.Хозрасчетный КАК Хозрасчетный
	|
	|ГДЕ
	|	(Хозрасчетный.Валютный = ИСТИНА)";
	
	Выборка   = Запрос.Выполнить().Выбрать();

	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	СтруктураПараметров = Новый Структура("ВалютаДокумента,КурсДокумента,КратностьДокумента");
	СтруктураПараметров.Вставить("Организация",                   СтруктураШапкиДокумента.Организация);
	СтруктураПараметров.Вставить("Период",                        КонецМесяца(Дата));
	СтруктураПараметров.Вставить("Заголовок",                     Заголовок);
	СтруктураПараметров.Вставить("ИспользоватьКурсИзСправочника", Истина);

	ПроводкиБУ = Движения.Хозрасчетный;
	
	УчетнаяПолитикаРегл = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитикиРегл(Дата, СтруктураШапкиДокумента.Организация);	
	
	СтруктураПараметров.Вставить("СчетаУчетаКР", БухгалтерскийУчет.ПараметрыУчетаКурсовыхРазниц(УчетнаяПолитикаРегл.ИспользуемыеКлассыСчетовРасходов));
	СтруктураПараметров.Вставить("ЕстьНалогНаПрибыль", СтруктураШапкиДокумента.ЕстьНалогНаПрибыль);
	
	Пока Выборка.Следующий() Цикл

		БухгалтерскийУчет.ПереоценкаСчетаРегл(СтруктураПараметров, ПроводкиБУ, Новый Структура("Счет",Выборка.СчетПереоценки), мВалютаРегламентированногоУчета, Ложь, Истина);

	КонецЦикла;
	
КонецПроцедуры

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры: 
//  РежимПроведения           - режим проведения документа (оперативный или неоперативный),
//  СтруктураШапкиДокумента   - выборка из результата запроса по шапке документа,
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоПодотчетникам, ТаблицаПоВзаиморасчетам, 
							ТаблицаПоРасчетам, ТаблицаПоДенежнымСредствам, ТаблицаПоДенежнымСредствамКПолучению, ТаблицаПоДенежнымСредствамВПути, Отказ, Заголовок)

	Если ОтражатьВУправленческомУчете Тогда
		ДвиженияПорегистрамВзаиморасчетыСПодотчетнымиЛицамиУпр(РежимПроведения, СтруктураШапкиДокумента, 
		                        ТаблицаПоПодотчетникам, Отказ, Заголовок);

		ДвиженияПорегистрамВзаиморасчетыСКонтрагентамиУпр(РежимПроведения, СтруктураШапкиДокумента, 
		                        ТаблицаПоВзаиморасчетам,ТаблицаПоРасчетам, Отказ, Заголовок);

		ДвиженияПорегистрамДенежныеСредстваУпр(РежимПроведения, СтруктураШапкиДокумента, 
		                        ТаблицаПоДенежнымСредствам, ТаблицаПоДенежнымСредствамКПолучению,  ТаблицаПоДенежнымСредствамВПути, Отказ, Заголовок);

	Иначе
		ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, РежимЗаписи, РежимПроведения) 

	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;

	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	ТаблицаПоПодотчетникам     = Новый ТаблицаЗначений;
	ТаблицаПоВзаиморасчетам    = Новый ТаблицаЗначений;
	ТаблицаПоРасчетам          = Новый ТаблицаЗначений;
	ТаблицаПоДенежнымСредствам = Новый ТаблицаЗначений;

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = "Проведение документа """ + СокрЛП(Ссылка) + """: ";

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = УправлениеЗапасами.СформироватьДеревоПолейЗапросаПоШапке();
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы", "ВалютаУправленческогоУчета",     "ВалютаУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы", "КурсВалютыУправленческогоУчета", "КурсВалютыУправленческогоУчета");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);

	Если ВзаиморасчетыСПодотчетнымиЛицами Тогда
		ТаблицаПоПодотчетникам = ПодготовитьТаблицуПоПодотчетникам(СтруктураШапкиДокумента);
	КонецЕсли;

	Если ВзаиморасчетыСКонтрагентами Тогда
		ТаблицаПоВзаиморасчетам = ПодготовитьТаблицуПоВзаиморасчетам(СтруктураШапкиДокумента);
		ТаблицаПоРасчетам       = ПодготовитьТаблицуПоРасчетам(СтруктураШапкиДокумента);
	КонецЕсли;

	Если ДенежныеСредстваВКассах ИЛИ ДенежныеСредстваНаБанковскихСчетах Тогда
		ТаблицаПоДенежнымСредствам = ПодготовитьТаблицуПоДенежнымСредствам(СтруктураШапкиДокумента);
		ТаблицаПоДенежнымСредствамКПолучению = ПодготовитьТаблицуПоДенежнымСредствамКПолучению(СтруктураШапкиДокумента);
	КонецЕсли;

	Если ДенежныеСредстваВПути Тогда
		ТаблицаПоДенежнымСредствамВПути = ПодготовитьТаблицуПоДенежнымСредствамВПути(СтруктураШапкиДокумента);
	КонецЕсли;
	
	// Движения по документу
	Если Не Отказ Тогда

		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоПодотчетникам, ТаблицаПоВзаиморасчетам, 
		                    ТаблицаПоРасчетам, ТаблицаПоДенежнымСредствам, ТаблицаПоДенежнымСредствамКПолучению, ТаблицаПоДенежнымСредствамВПути, Отказ, Заголовок);
							
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
	 
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью


мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");
