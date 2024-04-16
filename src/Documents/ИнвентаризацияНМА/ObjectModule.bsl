Перем мУдалятьДвижения;

// Строки, хранят реквизиты имеющие смысл только для бух. учета и упр. соответственно
// в случае если документ не отражается в каком-то виде учета, делаются невидимыми

Перем мСтрокаРеквизитыБухУчета Экспорт; // (Регл)
Перем мСтрокаРеквизитыУпрУчета Экспорт; // (Упр)
Перем мСтрокаРеквизитыНалУчета Экспорт; // (Регл)


////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Процедура заполняет структуры именами реквизитов, которые имеют смысл
// только для определенного вида учета
//
Процедура ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета() Экспорт

	ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаУпр();
	ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаРегл();

КонецПроцедуры // ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета()

// Процедура заполняет структуры именами реквизитов, которые имеют смысл
// только для управленческого учета
//
Процедура ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаУпр()

	мСтрокаРеквизитыУпрУчета =  "Подразделение,
								|МОЛ,
								|НематериальныеАктивы.КоличествоУУ,
								|НематериальныеАктивы.КоличествоПоФактуУУ,
								|НематериальныеАктивы.РасхожденияУУ,
								|НематериальныеАктивы.ПримечанияУУ
								|";

КонецПроцедуры // ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаУпр()

// Процедура заполняет структуры именами реквизитов, которые имеют смысл
// только для регламентированного учета
//
Процедура ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаРегл()

	мСтрокаРеквизитыБухУчета =  "ПодразделениеОрганизации,
								|МОЛОрганизации,
								|НематериальныеАктивы.КоличествоБУ,
								|НематериальныеАктивы.КоличествоПоФактуБУ,
								|НематериальныеАктивы.РасхожденияБУ,
								|НематериальныеАктивы.ПримечанияБУ
								|";
	мСтрокаРеквизитыНалУчета = "";

КонецПроцедуры // ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчетаРегл()

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой "НА-4"
//
// Параметры:
//  Нет.
//
// Возвращаемое значение:
//  Табличный документ - печатная форма сличительной ведомости.
//
Функция ПечатьНА4() Экспорт

	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ИнвентаризацияНМА.Дата КАК Дата,
	|	ИнвентаризацияНМА.Номер КАК Номер,
	|	ИнвентаризацияНМА.Организация КАК Организация,
	|	ИнвентаризацияНМА.Организация.НаименованиеПолное КАК ОрганизацияНаименованиеПолное,
	|	ИнвентаризацияНМА.ПодразделениеОрганизации.Представление КАК ПодразделениеПредставление,
	|	ИнвентаризацияНМА.ПодразделениеОрганизации.Код КАК ПодразделениеКод,
	|	ИнвентаризацияНМА.ДатаНачалаИнвентаризации КАК ДатаНачалаИнвентаризации,
	|	ИнвентаризацияНМА.ДатаОкончанияИнвентаризации КАК ДатаОкончанияИнвентаризации,
	|	ИнвентаризацияНМА.ДокументОснованиеВид КАК ДокументОснованиеВид,
	|	ИнвентаризацияНМА.ДокументОснованиеДата КАК ДокументОснованиеДата,
	|	ИнвентаризацияНМА.ДокументОснованиеНомер КАК ДокументОснованиеНомер
	|ИЗ
	|	Документ.ИнвентаризацияНМА КАК ИнвентаризацияНМА
	|ГДЕ
	|	ИнвентаризацияНМА.Ссылка = &Ссылка";
	
	Док = Запрос.Выполнить().Выбрать();
	Док.Следующий();
	
	//ВыборкаПоКомиссии = РаботаСДиалогами.ПолучитьСведенияОКомиссии(ЭтотОбъект);

	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("Ссылка",      Ссылка);
	Запрос.УстановитьПараметр("Организация", Док.Организация);
	Запрос.УстановитьПараметр("Дата",        Док.Дата);
	Запрос.УстановитьПараметр("СубконтоНМА", ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.НематериальныеАктивы);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ИнвентаризацияНМАНМА.НомерСтроки КАК НомерСтроки,
	|	ИнвентаризацияНМАНМА.НематериальныйАктив КАК НематериальныйАктив,
	|	ИнвентаризацияНМАНМА.НематериальныйАктив.НаименованиеПолное КАК НематериальныйАктивНаименованиеПолное,
	|	ИнвентаризацияНМАНМА.КоличествоБУ КАК Количество,
	|	ИнвентаризацияНМАНМА.КоличествоПоФактуБУ КАК ФактКоличество,
	|	ПервоначальныеСведенияНМА.ПервоначальнаяСтоимость КАК ПервоначальнаяСтоимость,
	|	ПервоначальныеСведенияНМА.СрокПолезногоИспользования КАК СрокПолезногоИспользования,
	|	АмортизацияНМА.АмортизацияОстаток КАК НакопленнаяАмортизация,
	|	АмортизацияНМА.СтоимостьОстаток КАК Стоимость
	|ИЗ
	|	Документ.ИнвентаризацияНМА.НематериальныеАктивы КАК ИнвентаризацияНМАНМА
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПервоначальныеСведенияНМАБухгалтерскийУчет.СрезПоследних(
	|				&Дата,
	|				Организация = &Организация
	|					И НематериальныйАктив В
	|						(ВЫБРАТЬ
	|							ИнвентаризацияНМАНМА.НематериальныйАктив
	|						ИЗ
	|							Документ.ИнвентаризацияНМА.НематериальныеАктивы КАК ИнвентаризацияНМАНМА
	|						ГДЕ
	|							ИнвентаризацияНМАНМА.Ссылка = &Ссылка)) КАК ПервоначальныеСведенияНМА
	|		ПО ИнвентаризацияНМАНМА.НематериальныйАктив = ПервоначальныеСведенияНМА.НематериальныйАктив
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.СтоимостьНМАБухгалтерскийУчет.Остатки(
	|				&Дата,
	|				Организация = &Организация
	|					И НематериальныйАктив В
	|						(ВЫБРАТЬ
	|							ИнвентаризацияНМАНМА.НематериальныйАктив
	|						ИЗ
	|							Документ.ИнвентаризацияНМА.НематериальныеАктивы КАК ИнвентаризацияНМАНМА
	|						ГДЕ
	|							ИнвентаризацияНМАНМА.Ссылка = &Ссылка)) КАК АмортизацияНМА
	|		ПО ИнвентаризацияНМАНМА.НематериальныйАктив = АмортизацияНМА.НематериальныйАктив
	|			И (АмортизацияНМА.Организация = &Организация)
	|ГДЕ
	|	ИнвентаризацияНМАНМА.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки";
	ТаблицаНМА = Запрос.Выполнить().Выгрузить();
	
	Макет = ПолучитьМакет("НА4");
	// печать производится на языке, указанном в настройках пользователя
	//КодЯзыкаПечать = Локализация.ПолучитьЯзыкФормироваияПечатныхФорм(УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "РежимФормированияПечатныхФорм"));
	КодЯзыкаПечать = "uk";
	//Макет.КодЯзыкаМакета = КодЯзыкаПечать;
	Макет.КодЯзыкаМакета = "ru";
	
	// Получаем области макета для вывода в табличный документ
	Шапка 				= Макет.ПолучитьОбласть("Шапка");
	ЗаголовокТаблицы 	= Макет.ПолучитьОбласть("ЗаголовокТаблицы");
	СтрокаТаблицы 		= Макет.ПолучитьОбласть("СтрокаТаблицы");
	Подвал 				= Макет.ПолучитьОбласть("Подвал");
	Расписка			= Макет.ПолучитьОбласть("Расписка");
	
	ВыборкаПоКомиссии = РаботаСДиалогами.ПолучитьСведенияОКомиссии(ЭтотОбъект);
	
	ТабДокумент = Новый ТабличныйДокумент;
	
	// Зададим параметры макета по умолчанию
	ТабДокумент.ПолеСверху              = 10;
	ТабДокумент.ПолеСлева               = 0;
	ТабДокумент.ПолеСнизу               = 0;
	ТабДокумент.ПолеСправа              = 0;
	ТабДокумент.РазмерКолонтитулаСверху = 10;
	ТабДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Ландшафт;
	//ТабДокумент.АвтоМасштаб             = Истина;
	
	// Загрузим настройки пользователя
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ИнвентаризацияНМА_НА4";

	// Выведем шапку документа
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Док.Организация, Док.Дата);
	
	Шапка.Параметры.Заполнить(Док);
	Шапка.Параметры.НаименованиеПолноеОрганизации 	= Док.ОрганизацияНаименованиеПолное;
	Шапка.Параметры.ЕДРПОУ 							= УправлениеКонтактнойИнформацией.ПолучитьКодОрганизации(СведенияОбОрганизации);
	// краткий формат дат
	Шапка.Параметры.ДокументОснованиеДата 			= Формат(Док.ДокументОснованиеДата, 		"ДЛФ=DD;Л =" + Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыкаПечать));
	Шапка.Параметры.ДатаНачалаИнвентаризации 		= Формат(Док.ДатаНачалаИнвентаризации, 		"ДЛФ=DD;Л =" + Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыкаПечать));
	Шапка.Параметры.ДатаОкончанияИнвентаризации 	= Формат(Док.ДатаОкончанияИнвентаризации, 	"ДЛФ=DD;Л =" + Локализация.ОпределитьКодЯзыкаДляФормат(КодЯзыкаПечать));
	
	Шапка.Параметры.НомерДок = Док.Номер;
	//Шапка.Параметры.ДатаДокумента  = Док.Дата;
	
	ТабДокумент.Вывести(Шапка);
	
	
	// Проверим, помещаются ли строка над таблицей, заголовок и первая строка.
	ШапкаТаблицы = Новый Массив;
	ШапкаТаблицы.Добавить(ЗаголовокТаблицы);
	ШапкаТаблицы.Добавить(СтрокаТаблицы);
	
	Если НЕ ФормированиеПечатныхФорм.ПроверитьВыводТабличногоДокумента(ТабДокумент, ШапкаТаблицы) Тогда			
		// Выведем разрыв страницы
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();

	КонецЕсли;
	
	// Сама таблица
	// Выведем заголовок таблицы	
	ТабДокумент.Вывести(ЗаголовокТаблицы);
	
	// Выведем строки таблицы
	Для Каждого СтрокаНМА Из ТаблицаНМА Цикл
		
		СтрокаТаблицы.Параметры.Заполнить(СтрокаНМА);
		
		ТабДокумент.Вывести(СтрокаТаблицы);
		
	КонецЦикла;
	
	
	// Подвал - члены комиссии
	Подвал.Параметры.Заполнить(ВыборкаПоКомиссии);
	
	// Сначала выведем членов комиссии из выборки
	//Для Каждого ЧленКомиссии Из НаименованиеЧленовКомиссии Цикл
	//	
	//	Подвал.Параметры[ЧленКомиссии + "Должность"] 	= ВыборкаПоКомиссии[ЧленКомиссии + "Должность"];
	//	Подвал.Параметры[ЧленКомиссии + "ФИО"] 			= ВыборкаПоКомиссии[ЧленКомиссии + "ФИО"];
	//	
	//КонецЦикла;
	
	
	// Проверим, помещаются ли шапка подписей и одна подпись
	ПодвалРасписка = Новый Массив;
	ПодвалРасписка.Добавить(Подвал);
	ПодвалРасписка.Добавить(Расписка);
	
	Если НЕ ФормированиеПечатныхФорм.ПроверитьВыводТабличногоДокумента(ТабДокумент, ПодвалРасписка) Тогда			
			
		// Выведем разрыв страницы
		ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();

	КонецЕсли;
	
	ТабДокумент.Вывести(Подвал);
	
	Расписка.Параметры.НомерДок = Док.Номер;
	
	ТабДокумент.Вывести(Расписка);
	
	
	Возврат ТабДокумент;
	
КонецФункции // ПечатьНА4()
	
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
	ИначеЕсли Не УправлениеДопПравамиПользователей.РазрешитьПечатьНепроведенныхДокументов(Проведен) Тогда
		Предупреждение("Недостаточно полномочий для печати непроведенного документа!");
		Возврат;
	КонецЕсли;

	Если Не РаботаСДиалогами.ПроверитьМодифицированность(ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	// Получить экземпляр документа на печать
	Если ИмяМакета = "НА4бух" Тогда
		
		ТабДокумент = ПечатьНА4();
		
	ИначеЕсли ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), Ссылка);

КонецПроцедуры // Печать

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	СтруктураМакетов = Новый Структура;
	
	СтруктураМакетов.Вставить("НА4бух", "Форма НА-4");
	
	Возврат СтруктураМакетов;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

#КонецЕсли

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА


////////////////////////////////////////////////////////////////////////////////
// ПРОВЕРКИ ПРАВИЛЬНОСТИ ЗАПОЛНЕНИЯ

// Формирует структуру полей, обязательных для заполнения при отражении фактического
// движения средств по банку.
//
// Возвращаемое значение:
//   СтруктураОбязательныхПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейШапки(СтруктураШапкиДокумента)

	СтруктураПолей = Новый Структура;

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплата()


// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧ(СтруктураШапкиДокумента, Отказ, Заголовок)

    СтруктураПолей = Новый Структура;
	
	СтруктураПолей.Вставить("НематериальныйАктив");
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "НематериальныеАктивы", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеТЧУпр

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧУпр(СтруктураШапкиДокумента, Отказ, Заголовок)

	
КонецПроцедуры // ПроверитьЗаполнениеТЧУпр

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧРегл(СтруктураШапкиДокумента, Отказ, Заголовок)

	
КонецПроцедуры // ПроверитьЗаполнениеТЧ


// Процедура проверяет правильность заполнения реквизитов документа
//
Процедура ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейШапки(СтруктураШапкиДокумента), Отказ, Заголовок);
	
	ПроверитьЗаполнениеТЧ(СтруктураШапкиДокумента, Отказ, Заголовок);
	
КонецПроцедуры

// Процедура проверяет правильность заполнения реквизитов документа
// для управленческого учета
Процедура ПроверитьЗаполнениеДокументаУпр(СтруктураШапкиДокумента, Отказ, Заголовок)

	Если НЕ СтруктураШапкиДокумента.ОтражатьВУправленческомУчете Тогда
		
		Возврат;
		
	КонецЕсли;

	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Подразделение");
	СтруктураПолей.Вставить("МОЛ");
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураПолей, Отказ, Заголовок);
	ПроверитьЗаполнениеТЧУпр(СтруктураШапкиДокумента, Отказ, Заголовок);

КонецПроцедуры

// Процедура проверяет правильность заполнения реквизитов документа
// для бухгалтерского и налогового (в общем регламентного) учета
Процедура ПроверитьЗаполнениеДокументаРегл(СтруктураШапкиДокумента, Отказ, Заголовок)

	Если (НЕ СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете ) Тогда
		
		Возврат;
		
	КонецЕсли;

	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация");
	СтруктураПолей.Вставить("ПодразделениеОрганизации");
	СтруктураПолей.Вставить("МОЛОрганизации");


	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураПолей, Отказ, Заголовок);
	ПроверитьЗаполнениеТЧРегл(СтруктураШапкиДокумента, Отказ, Заголовок);

КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
         
	мУдалятьДвижения = НЕ ЭтоНовый();
	
КонецПроцедуры // ПередЗаписью

Процедура ОбработкаПроведения(Отказ)
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента, Отказ, Заголовок);
	ПроверитьЗаполнениеДокументаУпр(СтруктураШапкиДокумента, Отказ, Заголовок);
	ПроверитьЗаполнениеДокументаРегл(СтруктураШапкиДокумента, Отказ, Заголовок);

КонецПроцедуры
