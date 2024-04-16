////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ПОЛУЧЕНИЯ НАСТРОЕК ОТЛОЖЕННОГО ПРОВЕДЕНИЯ

// Функция возвращает структуру параметров проведения документа
//
// Возвращаемое значение:
// 	<Структура> - структура содержащая свойства:
//				ДокументИспользуетсяВОтложенномПроведении - документ поддерживает отложенное проведение
//				ПроведениеПоВсемВидамУчета - выполняется полное проведение документа
//				ВыполняетсяДопроведение - выполняется допроведение документа
//				ВыполняетсяОтложенноеПроведение - выполняется отложенное проведение документа
//  Последние три свойства структуры имеют смысл, если ДокументИспользуетсяВОтложенномПроведении
Функция ПолучитьПараметрыПроведенияДокумента(ДокументОбъект) Экспорт
	
	СтруктураПараметров = Новый Структура("ДокументИспользуетсяВОтложенномПроведении, 
											|ПроведениеПоВсемВидамУчета, 
											|ВыполняетсяДопроведение, 
											|ВыполняетсяОтложенноеПроведение",Ложь,Ложь,Ложь, Ложь);
	
	СвойствоЭтапПроведения = Неопределено;
	СтруктураПараметров.ДокументИспользуетсяВОтложенномПроведении = ДокументОбъект.ДополнительныеСвойства.Свойство("ЭтапПроведения", СвойствоЭтапПроведения) 
												ИЛИ ОтложенноеПроведениеДокументов.ДокументПодерживаетОтложенноеПроведение(ДокументОбъект);
	Если СтруктураПараметров.ДокументИспользуетсяВОтложенномПроведении Тогда
		
		// Документ проводится в режиме допроведения,
		// если свойство ДополнительныеСвойства содержит ЭтапПроведения 
		// и данное свойство равно "Допроведение"
		
		Если СвойствоЭтапПроведения <> Неопределено Тогда
			СтруктураПараметров.ПроведениеПоВсемВидамУчета = (СвойствоЭтапПроведения = "ПроведениеПолностью");
			СтруктураПараметров.ВыполняетсяДопроведение    = (СвойствоЭтапПроведения = "Допроведение");
			СтруктураПараметров.ВыполняетсяОтложенноеПроведение = (СвойствоЭтапПроведения = "Проведение");
		Иначе
			СтруктураПараметров.ВыполняетсяОтложенноеПроведение = Истина;
		КонецЕсли; 
	КонецЕсли;
	
	Возврат СтруктураПараметров;
	
КонецФункции

//Функция возвращает дату начала отложенного проведения для указанной организации
//Если отложенное проведение для организации не используется, возвращается пустая дата
Функция ПолучитьДатуНачалаОтложенногоПроведения(Организация) Экспорт
	
	Запрос = Новый Запрос();
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Настройка.ДатаНачалаДействия 					КАК ДатаНачалаОтложенногоПроведения
		|ИЗ
		|	РегистрСведений.НастройкаОтложенногоПроведения 	КАК Настройка
		|ГДЕ
		|	Настройка.Организация = &Организация
		|	";
	Запрос.УстановитьПараметр("Организация",Организация);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда  //В выборке всегда будет только один элемент, т.к. в регистре только одно измерение Организация
		Возврат НачалоДня(Выборка.ДатаНачалаОтложенногоПроведения);
	КонецЕсли;
	
	Возврат Дата("00010101000000");
	
КонецФункции

// Функция возвращает список регистров, движения по которым формируются при допроведении
//
Функция ПолучитьРегистрыОтложенногоПроведения() Экспорт
	
	
	МассивРегистров = Новый Массив();
	
	МассивРегистров.Добавить("РегистрНакопления.БракВПроизводствеБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ВыпускПродукцииБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ВыпускПродукцииНаработкаБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ЗатратыБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ЗатратыНаВыпускПродукцииБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ЗатратыНаВыпускПродукцииНаработкаБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрБухгалтерии.Хозрасчетный");
	МассивРегистров.Добавить("РегистрНакопления.НезавершенноеПроизводствоБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ПартииТоваровНаСкладахБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.ПартииТоваровПереданныеБухгалтерскийУчет");
	МассивРегистров.Добавить("РегистрНакопления.РасчетыПоПриобретениюВВалютеОрганизации");
	МассивРегистров.Добавить("РегистрСведений.РасчетыПоПриобретениюОрганизации");
	МассивРегистров.Добавить("РегистрСведений.РасчетыПоРеализацииОрганизации");
	МассивРегистров.Добавить("РегистрНакопления.РасчетыПоРеализацииВВалютеОрганизации");
	МассивРегистров.Добавить("РегистрНакопления.РозничнаяВыручкаОрганизаций");
	МассивРегистров.Добавить("РегистрНакопления.УчетЗатратРегл");
	МассивРегистров.Добавить("РегистрНакопления.УчетПродажИСебестоимости");
	МассивРегистров.Добавить("РегистрНакопления.РеализованныеТовары");

	МассивРегистров.Добавить("РегистрСведений.ДокументыТребующиеДопроведения"); //Регистр включен в список, чтобы по нему очищались движения при допроведении

	Возврат МассивРегистров;
	
КонецФункции // ПолучитьРегистрыОтложенногоПроведения

//Функция возвращает: используется ли отложенное проведение для даты и организации, указанных в документе
//Используется в процедуре ДокументПодерживаетОтложенноеПроведение, а также в некоторых особых случаях
//	1. УправлениеЗапасами.ПриПроведенииРасширеннаяАналитикаЗапасовИзменениеСостоянияОбработкаПроведения (логика формирования движений по регистрам учета затрат)
//	2. модуль документа ВозвратТоваровОтПокупателя, процедура ПодготовитьСтруктуруШапкиДокумента
//Параметры: СтруктураШапкиДокумента - структура шапки документа
//				ДокументСсылка - ссылка на документ, передается если на момент вызова не известна СтруктураШапкиДокумента
Функция ИспользуетсяОтложенноеПроведение(СтруктураШапкиДокумента = Неопределено, ДокументСсылка = Неопределено) Экспорт
	Если СтруктураШапкиДокумента = Неопределено Тогда
		ДатаДокумента = ДокументСсылка.Дата;
		Попытка
			ОрганизацияДокумента = ДокументСсылка.Организация;
		Исключение
			Возврат Ложь;
		КонецПопытки;
	Иначе
		Если не СтруктураШапкиДокумента.Свойство("Организация") Тогда
			//Если в СтруктураШапкиДокумента отсутствует организация - такой документ не может поддерживать отложенное проведение
			Возврат Ложь;
		КонецЕсли;
		ДатаДокумента 			= СтруктураШапкиДокумента.Дата;
		ОрганизацияДокумента 	= СтруктураШапкиДокумента.Организация;
	КонецЕсли;	
	ДатаНачалаОтложенногоПроведения = ОтложенноеПроведениеДокументов.ПолучитьДатуНачалаОтложенногоПроведения(ОрганизацияДокумента);
	Возврат ЗначениеЗаполнено(ДатаНачалаОтложенногоПроведения) И ДатаНачалаОтложенногоПроведения <= ДатаДокумента;
КонецФункции

// Функция возвращает признак того, что документ используется в отложенном проведении
//
Функция ДокументПодерживаетОтложенноеПроведение(ДокументОбъект, СтруктураШапкиДокумента = Неопределено) Экспорт
	//Используется ли вообще отложенное проведение по дате и организации, указанным в документе
	Если НЕ ИспользуетсяОтложенноеПроведение(СтруктураШапкиДокумента,ДокументОбъект) Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат ДокументОбъект.Метаданные().Движения.Содержит(РегистрыСведений.ДокументыТребующиеДопроведения.СоздатьНаборЗаписей().Метаданные());
	
КонецФункции // ДокументПодерживаетОтложенноеПроведение

//Функция возвращает дату первого недопроведенного документа по организации за указанный интервал дат
//Параметры: 
//			Организация
//			ОграничениеНачалоИнтервала и ОграничениеКонецИнтервала		- даты начала и окончания анализируемого интервала 
//				(если не указаны, то период не ограничен)
//Возвращаемое значение: Дата (если все документы за указанный период допроведены, дата пустая)
Функция ПолучитьДатуПервогоНедопроведенногоДокумента(Организация,ОграничениеНачалоИнтервала = неопределено, ОграничениеКонецИнтервала = неопределено) Экспорт
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	Период
	|ИЗ 
	|	РегистрСведений.ДокументыТребующиеДопроведения
	|ГДЕ Активность 
	|	И Организация = &Организация "
	+?(ОграничениеНачалоИнтервала 	<> Неопределено, " И Период >= &ДатаНач ","")
	+?(ОграничениеКонецИнтервала 	<> Неопределено, " И Период <= &ДатаКон ","")+"
	|УПОРЯДОЧИТЬ ПО Период ВОЗР
	|";
	Запрос.УстановитьПараметр("ДатаНач",ОграничениеНачалоИнтервала);
	Запрос.УстановитьПараметр("ДатаКон",ОграничениеКонецИнтервала);
	Запрос.УстановитьПараметр("Организация",Организация);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Период;
	КонецЕсли;
	
	Возврат Дата("00010101000000");
	
КонецФункции

//Функция отсчитывает от указанной даты требуемое количество периодов назад
//Параметры: ТекДата - дата от которой необходимо отнять количество периодов
//		текПериодичность - период, который надо отнять (день либо месяц)
//		КоличествоПериодов - количество периодов которые надо отнять (должно быть положительное число)
//		флНачалоПериода - булево, признак того что необходимо вернуть начало периода. По умолчанию - ложь (возвращает конец периода)
Функция ОтсчитатьНазадКоличествоПериодов(ТекДата, ТекПериодичность, КоличествоПериодов, флНачалоПериода=Ложь) Экспорт
	Если КоличествоПериодов = 0 Тогда
		Если НЕ ЗначениеЗаполнено(ТекПериодичность) ИЛИ ТекПериодичность = Перечисления.Периодичность.День Тогда
			Возврат ?(флНачалоПериода, НачалоДня(ТекДата), КонецДня(ТекДата));
		Иначе
			Возврат ?(флНачалоПериода, НачалоМесяца(ТекДата), КонецМесяца(ТекДата));
		КонецЕсли;
	КонецЕсли;
	
	//Периодичность ограничена - либо день, либо месяц
	//Другие периоды в форме настройки выбирать не разрешено
	Если ТекПериодичность = Перечисления.Периодичность.Месяц Тогда
		РезультатРасчета = ДобавитьМесяц(ТекДата, -1 * КоличествоПериодов);
		Возврат ?(флНачалоПериода,НачалоМесяца(РезультатРасчета), КонецМесяца(РезультатРасчета));
	ИначеЕсли ТекПериодичность = Перечисления.Периодичность.День Тогда
		РезультатРасчета = ТекДата - КоличествоПериодов * 24*60*60;
		Возврат ?(флНачалоПериода,НачалоДня(РезультатРасчета), КонецДня(РезультатРасчета));;
	КонецЕсли;
	Возврат ?(флНачалоПериода,НачалоДня(ТекДата),КонецДня(ТекДата));
КонецФункции

//Функция возвращает период допроведения документов по настройке допроведения с учетом способа расчета дат: динамически или явно
//Параметры: Настройка (ссылка на настройку допроведения документов)
//Возвращаемое значение: структура с элементами НачалоИнтервала и КонецИнтервала
Функция ОпределитьПериодДопроведения(Настройка) Экспорт
	Результат = новый Структура("НачалоИнтервала,КонецИнтервала");
	//Начало интервала
	Если Настройка.РассчитыватьНачалоИнтервала Тогда
		Результат.НачалоИнтервала = ОтсчитатьНазадКоличествоПериодов(ТекущаяДата(),
																	Настройка.ПериодичностьОтставанияНачалоИнтервала,
																	Настройка.КоличествоПериодовОтставанияНачалоИнтервала, 
																	Истина);
	Иначе
		Результат.НачалоИнтервала = НачалоДня(Настройка.НачалоИнтервалаДопроведения);
	КонецЕсли;
	
	//Конец интервала
	Если Настройка.РассчитыватьКонецИнтервала Тогда
		Результат.КонецИнтервала = ОтсчитатьНазадКоличествоПериодов(ТекущаяДата(),
																	Настройка.ПериодичностьОтставанияКонецИнтервала,
																	Настройка.КоличествоПериодовОтставанияКонецИнтервала, 
																	Ложь);
	Иначе
		Результат.КонецИнтервала = КонецДня(Настройка.КонецИнтервалаДопроведения);
	КонецЕсли;
	Возврат Результат;
КонецФункции


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ПРОВЕДЕНИЯ ДОКУМЕНТА В РЕЖИМЕ ОТЛОЖЕННОГО ПРОВЕДЕНИЯ

//Обработчик подписки на событие "ПриПроведенииРегистрацияОтложенногоПроведения"
//Параметры: Источник - ДокументОбъект, который проводится
//			Отказ - булево, признак отказа
//			РежимПроведения - режим проведения документа
Процедура ПриПроведенииРегистрацияОтложенногоПроведения(Источник, Отказ, РежимПроведения) Экспорт
	Если НЕ Источник.ОтражатьВБухгалтерскомУчете 
		//Документ не поддерживает отложенное проведение - не надо писать его в регистр
		ИЛИ НЕ Источник.ДополнительныеСвойства.Свойство("ЭтапПроведения") Тогда
		Возврат;
	КонецЕсли;
	
	//Документ формирует движения в регистр только на этапе "Проведение"
	//Если документ допроводится либо проводится по всем видам учета - движения не формируются
	Если Источник.ДополнительныеСвойства.ЭтапПроведения = "Проведение" Тогда
		ПолныеПрава.РегистрацияОтложенногоПроведения(Источник.Ссылка, Источник.Организация);
	КонецЕсли;
КонецПроцедуры

//Подготовка документа к проведению с использованием механизма отложенного проведения:
//1. При необходимости (если еще не заполнено) заполняется дополнительное свойство "ЭтапПроведения"
//2. Вносятся изменения в СтруктураШапкиДокумента: 
//		в зависимости от действия (проведение / допроведение / проведение по всем регистрам) изменяются признаки отражения в учетах
//		в СтруктураШапкиДокумента
Процедура ПодготовитьКПроведениюПоВидамУчета(ДополнительныеСвойства, СтруктураШапкиДокумента) Экспорт
	Если ДополнительныеСвойства.Свойство("ЭтапПроведения") Тогда
		//Доп свойство установлено "снаружи" - это значит что производится
		//- либо допроведение документа
		//- либо "проведение по всем учетам"
		//- либо выполняется повторное проведение документа без закрытия формы
		
		//Признак отражения в упр. учете изменяется с учетом этапа проведения:
		//Если этап - допроведение, документ по УУ не проводится
		//Если этап - проведение по всем учетам, признак УУ не изменяется
		Если ДополнительныеСвойства.ЭтапПроведения = "Допроведение" Тогда
			СтруктураШапкиДокумента.ОтражатьВУправленческомУчете 	= Ложь;
		КонецЕсли;
	Иначе
		//Если доп свойство не установлено, документ проводится
		ДополнительныеСвойства.Вставить("ЭтапПроведения", "Проведение");
	КонецЕсли;
	//Выполняется отложенное проведение: документ по БУ не проводится
	Если ДополнительныеСвойства.ЭтапПроведения = "Проведение" Тогда
		СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете 	= Ложь;
	КонецЕсли;
КонецПроцедуры

//Функция проверяет, проведен ли документ полностью - по всем регистрам
//Параметры:  ДокументСсылка - ссылка на проверяемый документ (может быть как проведен, так и не проведен)
//Возвращаемое значение: булево (Истина - проведен полностью, Ложь - не проведен полностью)
//Вызывается из процедуры НастройкаПравДоступа.ПроверитьВозможностьОтраженияВРеглУчете
Функция ПроверитьДокументПроведенПолностью(ДокументСсылка) Экспорт
	
	Если не ДокументСсылка.Проведен Тогда
		Возврат Ложь;
	КонецЕсли;
	Если НЕ ДокументПодерживаетОтложенноеПроведение(ДокументСсылка) Тогда
		Возврат Истина;
	КонецЕсли;

	//Создадим массив для проверки документов
	МассивТипов = новый Массив;
	МассивТипов.Добавить(ТипЗнч(ДокументСсылка));
	
	МассивДокументов = Новый Массив;
	МассивДокументов.Добавить(ДокументСсылка);
	
	//Вызовем функцию проверки статуса для таблицы документов
	РезультатЗапроса = ПроверитьДокументыПроведеныПолностью(МассивДокументов, новый ОписаниеТипов(МассивТипов));
	//В результате всегда будет одна строка
	ВыборкаРезультат = РезультатЗапроса.Выбрать();
	ВыборкаРезультат.Следующий();
	Возврат ВыборкаРезультат.ПроведенПолностью;
КонецФункции

//Функция проверяет, проведены ли документы полностью - по всем регистрам
//Параметры:  МассивДокументов - массив из проверяемых документов.
//			ОписаниеТиповДокументов - описание типов, содержит типы которые имеются в массиве
//Возвращаемое значение: выборка из результата запроса с полями Документ (ссылка), Проведен (булево), ПометкаУдаления (булево) и ПроведенПолностью (булево)
//Используется в журнале ОтложенноеПроведениеДокументов и в функции ПроверитьДокументПроведенПолностью
Функция ПроверитьДокументыПроведеныПолностью(МассивДокументов, ОписаниеТиповДокументов) Экспорт
	//Создадим таблицу значений со списком документов
	ТаблицаДокументов = новый ТаблицаЗначений;
	ТаблицаДокументов.Колонки.Добавить("Документ",ОписаниеТиповДокументов);
	Для каждого Элемент из МассивДокументов цикл
		СтрокаТаблицы = ТаблицаДокументов.Добавить();
		СтрокаТаблицы.Документ = Элемент;
	КонецЦикла;

	МенеджерВременныхТаблиц = новый МенеджерВременныхТаблиц();
	//Запрос для создания временной таблицы
	Запрос = Новый Запрос();
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	Запрос.Текст = "ВЫБРАТЬ 
	|	Таб.Документ КАК Документ
	|	Поместить ВременнаяТаблицаДокументов
	|ИЗ &ТаблицаСсылок КАК Таб";
	Запрос.УстановитьПараметр("ТаблицаСсылок",ТаблицаДокументов);
	Запрос.Выполнить();
	
	//Запрос для получения данных из временных таблиц
	Запрос = Новый Запрос();
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВременнаяТаблицаДокументов.Документ 								КАК Документ,
	|	ЕстьNULL(ВременнаяТаблицаДокументов.Документ.Проведен, ЛОЖЬ)		КАК Проведен,
	|	ЕстьNULL(ВременнаяТаблицаДокументов.Документ.ПометкаУдаления,ЛОЖЬ) 	КАК ПометкаУдаления,
	|	ВЫБОР 
	//Если документ проведен и не отражается в БУ - документ проведен полностью
	|		КОГДА ВременнаяТаблицаДокументов.Документ.Проведен И 
	|			НЕ ВременнаяТаблицаДокументов.Документ.ОтражатьВБухгалтерскомУчете ТОГДА
	|			ИСТИНА
	|		КОГДА НЕ ВременнаяТаблицаДокументов.Документ.Проведен ТОГДА
	|			ЛОЖЬ
	//Если документ формирует движения по регистру ДокументыТребующиеДопроведения - документ не проведен полностью
	|		КОГДА ДокументыТребующиеДопроведения.Регистратор is not null ТОГДА
	|			ЛОЖЬ
	|		ИНАЧЕ
	|			ИСТИНА
	|	КОНЕЦ 													КАК ПроведенПолностью
	|ИЗ ВременнаяТаблицаДокументов
	|ЛЕВОЕ СОЕДИНЕНИЕ 
	|	РегистрСведений.ДокументыТребующиеДопроведения 			КАК ДокументыТребующиеДопроведения
	|	ПО ДокументыТребующиеДопроведения.Регистратор = ВременнаяТаблицаДокументов.Документ";
	Результат = Запрос.Выполнить();
	Возврат Результат;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ДОПРОВЕДЕНИЯ ДОКУМЕНТОВ

//Функция получает выборку документов, которые необходимо допровести
//Параметры: СтруктураПараметров 		- структура, содержащая параметры допроведения
//			Состав параметров:
//				Организация - организация, по которой необходимо выполнить допроведение
//				ДопроводитьВсеДокументы (булево) - признак, определяющий какие документы следует допроводить (все / только требующие допроведения)
//				ДатаНачала - дата, начиная с которой необходимо выполнять допроведение
//				ДатаОкончания 	- дата, по которую необходимо выполнять допроведение
//Возвращаемое значение: Выборка из результата запроса с полями Регистратор, Дата, МоментВремени
Функция ПолучитьВыборкуДопроведениеДокументов(СтруктураПараметров) 

	Запрос = новый Запрос();
	Если СтруктураПараметров.ДопроводитьВсеДокументы Тогда
		//Допроводятся все документы, которые удовлетворяют перечисленным ниже условиям
		//- Для данного вида документа предусмотрено отложенное проведение (является регистратором регистра сведений ДокументыТребующиеДопроведения)
		//- Проведен,
		//- Отражается в БУ
		//- Организация - соответствующая параметрам
		//- Дата документа попадает в период допроведения
		 ШаблонПодзапроса = "
		 	|ВЫБРАТЬ  
			|	Ссылка 					КАК Регистратор, 
			|	Ссылка.Дата 			КАК Дата
			|ИЗ Документ.%ИмяДокумента%
			|ГДЕ 
			|	Организация = &Организация 
			|	И Дата >= &ДатаНачала И Дата <= &ДатаОкончания
			|	И Проведен И ОтражатьВБухгалтерскомУчете
			|ОБЪЕДИНИТЬ ВСЕ";

		ТекстЗапроса = "";
		//Текст запроса складывается объединением из идентичных запросов по документам, которые являются регистраторами для регистра ДокументыТребующиеДопроведения
		РегистрМД = РегистрыСведений.ДокументыТребующиеДопроведения.СоздатьНаборЗаписей().Метаданные();
		Для каждого ДокументМД из Метаданные.Документы цикл
			Если НЕ ДокументМД.Движения.Содержит(РегистрМД) Тогда
				Продолжить;
			КонецЕсли;
			ТекстЗапроса = ТекстЗапроса + стрЗаменить(ШаблонПодзапроса,"%ИмяДокумента%", ДокументМД.Имя);
		КонецЦикла;
		//Уберем последнее ОБЪЕДИНИТЬ ВСЕ из текста запроса
		ТекстЗапроса = Лев(ТекстЗапроса, СтрДлина(ТекстЗапроса) - 14);
		
		ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Подзапрос.Регистратор, 
		|	Подзапрос.Дата
		|ИЗ ("+ТекстЗапроса+") КАК Подзапрос
		|Упорядочить по Подзапрос.Дата";
		
	Иначе
		//Допроводятся документы указанной организации,
		//которые сформировали движения по регистру ДокументыТребующиеДопроведения и расположены в периоде допроведения
		ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	Регистратор, 
		|	Период КАК Дата
		|ИЗ РегистрСведений.ДокументыТребующиеДопроведения
		|ГДЕ Организация=&Организация И Активность
		|	И Период >= &ДатаНачала И Период <= &ДатаОкончания
		|УПОРЯДОЧИТЬ ПО Период";
	КонецЕсли;
	
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("ДатаНачала",СтруктураПараметров.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания",СтруктураПараметров.ДатаОкончания);
	Запрос.УстановитьПараметр("Организация", СтруктураПараметров.Организация);
	Возврат Запрос.Выполнить().Выбрать();
КонецФункции

//Функция выполняет собственно допроведение документов
//Возвращает булево - успешность проведения документов.
//Параметры: СтруктураПараметров 		- структура, содержащая параметры допроведения
//			Состав параметров:
//				Организация - организация, по которой необходимо выполнить допроведение
//				ДопроводитьВсеДокументы (булево) - признак, определяющий какие документы следует допроводить (все / только требующие допроведения)
//				ДатаНачала - дата, начиная с которой необходимо выполнять допроведение
//				ДатаОкончания 	- дата, по которую необходимо выполнять допроведение
Функция ВыполнитьДопроведениеДокументов(СтруктураПараметров)
	Перем ВыполненоУспешно;
	
	Заголовок = "Допроведение документов по организации " + СтруктураПараметров.Организация;
	
	Выборка = ПолучитьВыборкуДопроведениеДокументов(СтруктураПараметров);
	
	//Откроем форму прогрессора
	#Если Клиент Тогда
	мКоличествоДокументов = Выборка.Количество();
	мФормаПрогрессора = Неопределено;
	//Для небольшого количества документов не имеет смысл показывать форму прогрессора
	Если мКоличествоДокументов > 2 Тогда
		мФормаПрогрессора = ПолучитьОбщуюФорму("ХодВыполненияОбработкиДанных");
		мФормаПрогрессора.НаименованиеОбработкиДанных = "Допроведение документов";
		мФормаПрогрессора.КомментарийОбработкиДанных = "Организация: "+ СтруктураПараметров.Организация;
		мФормаПрогрессора.Значение = 0;
		мФормаПрогрессора.МаксимальноеЗначение = мКоличествоДокументов;
		мФормаПрогрессора.КомментарийЗначения = "Допроведение документов ...";
		мФормаПрогрессора.Открыть();
		мНомерОбрабатываемогоДокумента = 0;
	КонецЕсли;
	
	#КонецЕсли	
	мСоответствиеОшибокПриДопроведении = Новый Соответствие();
	мДопроведениеПрекращено = Ложь;
	Пока Выборка.Следующий() цикл
		//Отразим обработку следующего документа на форме прогрессора
		#Если Клиент Тогда
		ОбработкаПрерыванияПользователя();
		Если мФормаПрогрессора <> Неопределено Тогда
			мНомерОбрабатываемогоДокумента 			= мНомерОбрабатываемогоДокумента + 1;
			мФормаПрогрессора.Значение 				= мНомерОбрабатываемогоДокумента;
			мФормаПрогрессора.КомментарийЗначения 	= "Допроводится " + мНомерОбрабатываемогоДокумента + " документ из " + мКоличествоДокументов;
		КонецЕсли;
		#КонецЕсли
		ТекДокумент = Выборка.Регистратор;
		Попытка
			ДокОбъект = ТекДокумент.ПолучитьОбъект();
			ДокОбъект.ДополнительныеСвойства.Вставить("ЭтапПроведения", "Допроведение");
			ДокОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
		Исключение
			мСоответствиеОшибокПриДопроведении.Вставить(ТекДокумент,ОписаниеОшибки());
		КонецПопытки;
		Если мСоответствиеОшибокПриДопроведении.Количество() = 1000 Тогда
			мДопроведениеПрекращено = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	//Закроем форму прогрессора
	#Если Клиент Тогда
	Если мФормаПрогрессора <> Неопределено И мФормаПрогрессора.Открыта() Тогда
		мФормаПрогрессора.Закрыть();
	КонецЕсли;
	#КонецЕсли
	Если мСоответствиеОшибокПриДопроведении.Количество() = 0 Тогда
		Возврат Истина; //Возвращаем признак успешного выполнения
	КонецЕсли;
	//Выведем сведения об ошибках
	ОбщегоНазначения.СообщитьОбОшибке("При допроведении документов произошли ошибки!",,Заголовок);
	Для каждого Элемент из мСоответствиеОшибокПриДопроведении цикл
		СтрокаСообщения = "" + ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Элемент.Ключ) + 
									Символы.ПС+"Допроведение документа не выполнено: " + Элемент.Значение; 
		ОбщегоНазначения.СообщитьОбОшибке(СтрокаСообщения,,Заголовок,,Элемент.Ключ);
	КонецЦикла;
	Если мДопроведениеПрекращено Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Получено 1000 сообщений об ошибках. После этого допроведение было прекращено",, Заголовок);
	КонецЕсли;
	Возврат Ложь;
КонецФункции

//Процедура запускает допроведение документов по нескольким организациям
//Параметры:
//	ТаблицаОрганизаций: таблица значений, содержащая колонки Организация И ДатаНачалаОтложенногоПроведения
//	ПараметрыДопроведения: структура, содержащая следующие параметры:
//		ДатаНачала - дата начала периода допроведения
//		ДатаОкончания - дата окончания периода допроведения
//		ДопроводитьВсеДокументы - булево, признак какие документы следует допроводить (все (истина) либо только требующие допроведения (ложь))
Процедура ВыполнитьДопроведениеДокументовПоСпискуОрганизаций(ТаблицаОрганизаций, ПараметрыДопроведения) Экспорт
	Если ТаблицаОрганизаций.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	Для Каждого СтрокаТаблицы ИЗ ТаблицаОрганизаций Цикл
		НачДата = ?(СтрокаТаблицы.ДатаНачалаОтложенногоПроведения > ПараметрыДопроведения.ДатаНачала, СтрокаТаблицы.ДатаНачалаОтложенногоПроведения, ПараметрыДопроведения.ДатаНачала);
		Если НачДата > КонецДня(ПараметрыДопроведения.ДатаОкончания) Тогда
			Продолжить;
		КонецЕсли;
		ТекОрганизация = СтрокаТаблицы.Организация;
		ЗаголовокСообщ = "Допроведение документов по организации " + ТекОрганизация;
		ПараметрыДопроведенияПоОрганизации = Новый Структура("Организация, 
												|ДопроводитьВсеДокументы, 
												|ДатаНачала, ДатаОкончания", 
												ТекОрганизация, 
												ПараметрыДопроведения.ДопроводитьВсеДокументы, 
												НачалоДня(НачДата), 
												КонецДня(ПараметрыДопроведения.ДатаОкончания));
		ДопроведениеВыполнено = ВыполнитьДопроведениеДокументов(ПараметрыДопроведенияПоОрганизации);
		Если ДопроведениеВыполнено Тогда
			//Проверим все ли документы допровелись
			ДатаПервогоНедопроведенногоДокумента = ПолучитьДатуПервогоНедопроведенногоДокумента(ТекОрганизация, НачДата, ПараметрыДопроведения.ДатаОкончания);
			Если ЗначениеЗаполнено(ДатаПервогоНедопроведенногоДокумента) Тогда
				ДопроведениеВыполнено = Ложь;
			КонецЕсли;
		КонецЕсли;
		Если ДопроведениеВыполнено Тогда
			ТекстСообщения = "Допроведение выполнено успешно";
			ОбщегоНазначения.Сообщение(ТекстСообщения,,ЗаголовокСообщ);
		Иначе
			ТекстСообщения = "Не все требуемые документы допроведены. Допроведение не выполнено.";
			ОбщегоНазначения.СообщитьОбОшибке(ТекстСообщения, , ЗаголовокСообщ);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

