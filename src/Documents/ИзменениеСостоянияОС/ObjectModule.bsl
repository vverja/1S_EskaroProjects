Перем мУдалятьДвижения;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
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

	Если ТипЗнч(ИмяМакета) = Тип("ДвоичныеДанные") Тогда

		ТабДокумент = УниверсальныеМеханизмы.НапечататьВнешнююФорму(Ссылка, ИмяМакета);
		
		Если ТабДокумент = Неопределено Тогда
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Процедура определяет параметры учетной политики
//
Процедура ПодготовитьПараметрыУчетнойПолитики(СтруктураШапкиДокумента, Отказ, Заголовок)

	ПодготовитьПараметрыУчетнойПолитикиУпр(СтруктураШапкиДокумента, Отказ, Заголовок);
	ПодготовитьПараметрыУчетнойПолитикиРегл(СтруктураШапкиДокумента, Отказ, Заголовок);
	
КонецПроцедуры // ПодготовитьПараметрыУчетнойПолитики()

// Процедура определяет параметры упр. учетной политики
//
Процедура ПодготовитьПараметрыУчетнойПолитикиУпр(СтруктураШапкиДокумента, Отказ, Заголовок)

	Если ОтражатьВУправленческомУчете Тогда
		
	КонецЕсли;

КонецПроцедуры // ПодготовитьПараметрыУчетнойПолитикиУпр()

// Процедура определяет параметры регл. учетной политики
//
Процедура ПодготовитьПараметрыУчетнойПолитикиРегл(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	Если ОтражатьВБухгалтерскомУчете Тогда
		
		// Прежде всего, проверим заполнение реквизита Организация в шапке документа
		СтруктураОбязательныхПолей = Новый Структура;
		СтруктураОбязательныхПолей.Вставить("Организация");
		// Теперь позовем общую процедуру проверки
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
		// Организация не заполнена, получать учетную политику нет смысла
		Если Отказ Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ОтражатьВБухгалтерскомУчете Тогда
		
		мУчетнаяПолитикаРегл = ОбщегоНазначения.ПолучитьПараметрыУчетнойПолитикиРегл(КонецМесяца(Дата), Организация);
		
		Если НЕ ЗначениеЗаполнено(мУчетнаяПолитикаРегл) Тогда
			Отказ = Истина;
		КонецЕсли;
		
		Если НЕ Отказ Тогда
			
			СтруктураШапкиДокумента.Вставить("ЕстьНалогНаПрибыль" , мУчетнаяПолитикаРегл.ЕстьНалогНаПрибыль);
			СтруктураШапкиДокумента.Вставить("ЕстьНДС"            , мУчетнаяПолитикаРегл.ЕстьНДС);
			
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры // ПодготовитьПараметрыУчетнойПолитикиРегл()

Функция ПолучитьСписокЗначенийВидыСобытий() Экспорт
	
	ВидыСобытий = Новый СписокЗначений;
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.ВводВЭксплуатацию);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.ВнутреннееПеремещение);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.ЧастичнаяЛиквидация);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.Ремонт);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.Модернизация);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.ПодготовкаКПередаче);
	ВидыСобытий.Добавить(Перечисления.ВидыСобытийОС.Прочее);
	
	Возврат ВидыСобытий;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// ДВИЖЕНИЯ ПО РЕГИСТРАМ

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)

	ДвиженияПоРегистрамУпр(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);
	ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)
	
КонецПроцедуры // ДвиженияПоРегистрам

Процедура ДвиженияПоРегистрамУпр(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)

	Если Не СтруктураШапкиДокумента.ОтражатьВУправленческомУчете Тогда
		
		Возврат
		
	КонецЕсли;
	
	ДатаДока					= Дата;
	СобытиеОС					= Движения.СобытияОС;
	НачислениеАмортизацииОС		= Движения.НачислениеАмортизацииОС;
	СостояниеОС					= Движения.СостоянияОС;
	НазваниеДокумента			= Метаданные().Представление();
	
	Для каждого СтрокаТЧ Из ТаблицаПоОС Цикл
		
		Движение = СобытиеОС.Добавить();
		Движение.Период                   = ДатаДока;
		Движение.ОсновноеСредство         = СтрокаТЧ.ОсновноеСредство;
		Движение.Событие                  = СтруктураШапкиДокумента.Событие;
		Движение.НомерДокумента           = Номер;
		Движение.НазваниеДокумента        = НазваниеДокумента;
		
		// Движения по регистру СостоянияОС
		Если СтруктураШапкиДокумента.Событие.ВидСобытияОС = Перечисления.ВидыСобытийОС.ВводВЭксплуатацию Тогда
			Движение = СостояниеОС.Добавить();
			Движение.ОсновноеСредство  = СтрокаТЧ.ОсновноеСредство;
			Движение.Состояние         = Перечисления.СостоянияОС.ВведеноВЭксплуатацию;
			Движение.ДатаСостояния     = ДатаДока;
		КонецЕсли;
		
		Если СтруктураШапкиДокумента.ВлияетНаНачислениеАмортизации Тогда
			
			Движение = НачислениеАмортизацииОС.Добавить();
			Движение.Период                             = ДатаДока;
			Движение.ОсновноеСредство                   = СтрокаТЧ.ОсновноеСредство;
			Движение.НачислятьАмортизацию               = СтруктураШапкиДокумента.НачислятьАмортизацию;
			Движение.НачислятьАмортизациюВТекущемМесяце = СтруктураШапкиДокумента.НачислятьАмортизациюВТекущемМесяце;
			
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ДвиженияПоРегистрамРегл(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок)
	
	Если Не СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете Тогда
		
		Возврат
		
	КонецЕсли;

	ДатаДока = Дата;

	//Получение данных о видах налоговой деятельности, к которым принадлежат ОС
	УправлениеВнеоборотнымиАктивами.ДополнитьТабличнуюЧастьСведениямиОбОСБухНалогРегл(МоментВремени(), СтруктураШапкиДокумента.Организация,
	                                                  ТаблицаПоОС, СтруктураШапкиДокумента,
													  Отказ, Заголовок);
	
	Если СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете Тогда
		
		СобытиеОСБух             = Движения.СобытияОСОрганизаций;
		НачислениеАмортизацииБух = Движения.НачислениеАмортизацииОСБухгалтерскийУчет;
		НачислениеАмортизацииНал = Движения.НачислениеАмортизацииОСНалоговыйУчет;
		
		СостояниеОС              = Движения.СостоянияОСОрганизаций;
		НазваниеДокумента        = Метаданные().Представление();
		
		Для каждого СтрокаТЧ Из ТаблицаПоОС Цикл
			
			Движение = СобытиеОСБух.Добавить();
			Движение.Период                   = ДатаДока;
			Движение.ОсновноеСредство         = СтрокаТЧ.ОсновноеСредство;
			Движение.Организация              = СтруктураШапкиДокумента.Организация;
			Движение.Событие                  = СтруктураШапкиДокумента.СобытиеРегл;
			Движение.НомерДокумента           = Номер;
			Движение.НазваниеДокумента        = НазваниеДокумента;
			
			// Движения по регистру сведений СостоянияОСОрганизаций
			Если СтруктураШапкиДокумента.СобытиеРегл.ВидСобытияОС = Перечисления.ВидыСобытийОС.ВводВЭксплуатацию Тогда
				
				Движение = СостояниеОС.Добавить();
				Движение.ОсновноеСредство  = СтрокаТЧ.ОсновноеСредство;
				Движение.Организация       = СтруктураШапкиДокумента.Организация;
				Движение.Состояние         = Перечисления.СостоянияОС.ВведеноВЭксплуатацию;
				Движение.ДатаСостояния     = ДатаДока;
				
			КонецЕсли;
			
			Если СтруктураШапкиДокумента.ВлияетНаНачислениеАмортизации Тогда
				
				Движение = НачислениеАмортизацииБух.Добавить();
				Движение.Период               = ДатаДока;
				Движение.ОсновноеСредство     = СтрокаТЧ.ОсновноеСредство;
				Движение.Организация          = СтруктураШапкиДокумента.Организация;
				Движение.НачислятьАмортизацию = СтруктураШапкиДокумента.НачислятьАмортизацию;
				
				Непроизводственное = СтрокаТЧ.ВидНалоговойДеятельности_ОС = Справочники.ВидыНалоговойДеятельности.НеОблагаемая;
				
				НачислятьАмортизациюНУ = СтруктураШапкиДокумента.НачислятьАмортизацию И НЕ Непроизводственное;
				
				// Движение по регистру сведений НачислениеАмортизацииОСНалоговыйУчет 
				Движение = НачислениеАмортизацииНал.Добавить();
				Движение.Период               = ДатаДока;
				Движение.ОсновноеСредство     = СтрокаТЧ.ОсновноеСредство;
				Движение.Организация          = СтруктураШапкиДокумента.Организация;
				Движение.НачислятьАмортизацию = НачислятьАмортизациюНУ;
					
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;

КонецПроцедуры


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
	
	СтруктураПолей.Вставить("ОсновноеСредство");
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеТЧУпр

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧУпр(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок)

	Если РежимПроведения = РежимПроведенияДокумента.Оперативный Тогда
		// Проверим возможность изменения состояния ОС
		Для каждого СтрокаОС из ОС Цикл
			УправлениеВнеоборотнымиАктивами.ПроверитьВозможностьИзмененияСостоянияОС(СтрокаОС.ОсновноеСредство,Дата,Событие,Отказ);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗаполнениеТЧУпр

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧРегл(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок)
 	
	// Проверка соответствия организации ОС и организации документа
	ТекОрганизация = Организация;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("ДатаСреза"     , МоментВремени());
	Запрос.УстановитьПараметр("ТекОрганизация", ТекОрганизация);
	Запрос.УстановитьПараметр("СписокОС"      , ОС.ВыгрузитьКолонку("ОсновноеСредство"));
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	МестонахождениеОС.ОсновноеСредство    КАК ОС
	               |ИЗ
	               |	РегистрСведений.МестонахождениеОСБухгалтерскийУчет.СрезПоследних(&ДатаСреза,
				   |	                Организация = &ТекОрганизация И ОсновноеСредство В (&СписокОС))
				   |	                КАК МестонахождениеОС";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Для каждого СтрокаОС Из ОС Цикл
		
		
		ТекОС = СтрокаОС.ОсновноеСредство;
	
		Если Не Выборка.НайтиСледующий(ТекОС, "ОС") Тогда
			
			ОбщегоНазначения.СообщитьОбОшибке("Строка " + СтрокаОС.НомерСтроки + "." + Символы.ПС + Символы.Таб
					+ "Бухг. учет: Основного средства """ + ТекОс + """ нет в наличии по организации """ + ТекОрганизация + """.",
					Отказ, Заголовок);
			
		КонецЕсли;
		
		Выборка.Сбросить();
	
	КонецЦикла;
	
	Если РежимПроведения = РежимПроведенияДокумента.Оперативный Тогда
		// Проверим возможность изменения состояния ОС
		Для каждого СтрокаОС из ОС Цикл
			УправлениеВнеоборотнымиАктивами.ПроверитьВозможностьИзмененияСостоянияОС(СтрокаОС.ОсновноеСредство,Дата,СобытиеРегл,Отказ,Организация);
		КонецЦикла;
	КонецЕсли;

	
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
Процедура ПроверитьЗаполнениеДокументаУпр(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок)

	Если НЕ СтруктураШапкиДокумента.ОтражатьВУправленческомУчете Тогда
		
		Возврат;
		
	КонецЕсли;
	
 	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Событие");

	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураПолей, Отказ, Заголовок);

	
	// Проверим чем заполнено событие
	ВидыСобытий = ПолучитьСписокЗначенийВидыСобытий();
	ПредставлениеРеквизита = ЭтотОбъект.Метаданные().Реквизиты.Событие.Представление();
	УправлениеВнеоборотнымиАктивами.ПроверкаЗаполненияСобытий(СтруктураШапкиДокумента.Событие.ВидСобытияОС,
							  ВидыСобытий,
							  ПредставлениеРеквизита,Отказ);
							  
	ПроверитьЗаполнениеТЧУпр(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок);
	
КонецПроцедуры

// Процедура проверяет правильность заполнения реквизитов документа
// для бухгалтерского и налогового (в общем регламентного) учета
Процедура ПроверитьЗаполнениеДокументаРегл(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок)

	Если (НЕ СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете ) Тогда
		
		Возврат;
		
	КонецЕсли;

	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("Организация");
	СтруктураПолей.Вставить("СобытиеРегл");

	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураПолей, Отказ, Заголовок);
	
	// Проверим чем заполнено событие
	ВидыСобытий = ПолучитьСписокЗначенийВидыСобытий();
	ПредставлениеРеквизита = ЭтотОбъект.Метаданные().Реквизиты.СобытиеРегл.Представление();
	УправлениеВнеоборотнымиАктивами.ПроверкаЗаполненияСобытий(СтруктураШапкиДокумента.СобытиеРегл.ВидСобытияОС,
							  ВидыСобытий,
							  ПредставлениеРеквизита,Отказ);
							  
	ПроверитьЗаполнениеТЧРегл(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если ТипЗнч(Основание) = Тип("СправочникСсылка.ОсновныеСредства") Тогда
		
		СтрокаТабличнойЧасти = ОС.Добавить();
		СтрокаТабличнойЧасти.ОсновноеСредство = Основание.Ссылка;
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	СтруктураШапкиДокумента.Вставить("ВидСобытияОС",СтруктураШапкиДокумента.Событие.ВидСобытияОС);
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Получим данные учетной политики
	ПодготовитьПараметрыУчетнойПолитики(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;

	ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента, Отказ, Заголовок);
	ПроверитьЗаполнениеДокументаУпр(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок);
	ПроверитьЗаполнениеДокументаРегл(РежимПроведения, СтруктураШапкиДокумента, Отказ, Заголовок);
	
	// Сформируем структуру табличной части
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство" , "ОсновноеСредство");
	
	РезультатЗапросаПоОС = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей);
	ТаблицаПоОС          = РезультатЗапросаПоОС.Выгрузить();
	
	
	//проверка, нет ли списанных ОС в табличной части
	УправлениеВнеоборотнымиАктивами.ПроверитьНаСписанность(Дата, Организация, ТаблицаПоОС, ОтражатьВУправленческомУчете, ОтражатьВБухгалтерскомУчете,
	                       Отказ, Заголовок);
	
	Если Не Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, ТаблицаПоОС, Отказ, Заголовок);
		
	КонецЕсли;

КонецПроцедуры // ОбработкаПроведения()

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
    	
	Если Не НачислятьАмортизацию Тогда
		
		НачислятьАмортизациюВТекущемМесяце = Ложь;		
		
	КонецЕсли;
	
	мУдалятьДвижения = НЕ ЭтоНовый();

	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
КонецПроцедуры
