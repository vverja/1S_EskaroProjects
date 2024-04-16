
Процедура МеханизмВерсионированияОбъектов_ПередЗаписьюСправочника(Источник, Отказ) Экспорт
	
	ПодготовитьЗаписьОбъекта (Источник);
	
КонецПроцедуры

Процедура МеханизмВерсионированияОбъектов_ПередЗаписьюДокумента(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	ПодготовитьЗаписьОбъекта (Источник, РежимЗаписи);
	
КонецПроцедуры

Процедура МеханизмВерсионированияОбъектов_ПриЗаписиСправочникаДокумента(Источник, Отказ) Экспорт
	
	ПараметрыВерсионирования = Источник.ДополнительныеСвойства;
	
	Если ПараметрыВерсионирования.Свойство("ВерсионироватьОбъект") Тогда
		Если ПараметрыВерсионирования.ВерсионироватьОбъект Тогда
			ЧислоВерсийОбъекта = ПараметрыВерсионирования.ЧислоВерсийОбъекта;
			
			ЗаписьXML = Новый ЗаписьXML;
			ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
			ЗаписьXML.ОткрытьФайл(ИмяВременногоФайла); 
			ЗаписьXML.ЗаписатьОбъявлениеXML();
			ЗаписатьXML(ЗаписьXML, Источник, НазначениеТипаXML.Явное);
			ЗаписьXML.Закрыть();
			ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
			ХранилищеДанных = Новый ХранилищеЗначения(ДвоичныеДанные);
			
			УдалитьФайлы(ИмяВременногоФайла);
			
			ВерсионированиеОбъектовПривилегированный.ЗаписатьВерсиюОбъекта(
			                               Источник.Ссылка,
			                               ЧислоВерсийОбъекта,
			                               ХранилищеДанных);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьЗаписьОбъекта(знач Источник,
                                   знач РежимЗаписи = Неопределено)
	
	// Проверяем, что механизм версионирования включен
	Если Константы.ИспользоватьВерсионированиеОбъектов.Получить() Тогда
		
		// получаем вариант версионирования из функциональной опции
		ВариантВерсионирования = ПолучитьВариантВерсионирования(Источник);
		
		ЧислоВерсийОбъекта = Неопределено;
		
		ВерсионироватьОбъект = Истина;
		Если ВариантВерсионирования = Перечисления.ВариантыВерсионированияОбъектов.НеВерсионировать Тогда
			ВерсионироватьОбъект = Ложь;
		ИначеЕсли ВариантВерсионирования = Перечисления.ВариантыВерсионированияОбъектов.ВерсионироватьПриПроведении Тогда
			ЧислоВерсийОбъекта = ВерсионированиеОбъектовПривилегированный.ПолучитьЧислоВерсийОбъекта(Источник.Ссылка);
			Если ЧислоВерсийОбъекта = 0 И РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
				ВерсионироватьОбъект = Ложь;
			КонецЕсли;
		КонецЕсли;
		
		ПараметрыВерсионирования = Источник.ДополнительныеСвойства;
		ПараметрыВерсионирования.Вставить("ВерсионироватьОбъект", ВерсионироватьОбъект);
		ПараметрыВерсионирования.Вставить("ЧислоВерсийОбъекта", ЧислоВерсийОбъекта);
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьВариантВерсионирования(Источник)
	
	ИмяОбъекта = Источник.Метаданные().Имя;
	
	НастройкаВерсионирования = РегистрыСведений.НастройкаВерсионированияОбъектов.СоздатьМенеджерЗаписи();
	НастройкаВерсионирования.ТипОбъекта = ИмяОбъекта;
	НастройкаВерсионирования.Прочитать();
	
	Если ЗначениеЗаполнено(НастройкаВерсионирования.Вариант) Тогда
		Возврат НастройкаВерсионирования.Вариант;
	Иначе
		Если Справочники.ТипВсеСсылки().СодержитТип(ТипЗнч(Источник.Ссылка)) Тогда
			Возврат Перечисления.ВариантыВерсионированияОбъектов.НеВерсионировать;
		Иначе
			Возврат ?(Источник.Метаданные() = Метаданные.СвойстваОбъектов.Проведение.Разрешить,
			          Перечисления.ВариантыВерсионированияОбъектов.ВерсионироватьПриПроведении,
			          Перечисления.ВариантыВерсионированияОбъектов.ВерсионироватьВсегда);
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

// Проверяет, что документу разрешено проведение
//
Функция ДокументПроводится(знач ИмяДокумента) Экспорт
	
	Возврат Метаданные.Документы[ИмяДокумента].Проведение = 
	            Метаданные.СвойстваОбъектов.Проведение.Разрешить;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Блок функций для работы с настройками значений

Процедура ЗаписатьНастройкиВерсионированияПоУмолчанию() Экспорт
	
	НВСправочники = Перечисления.ВариантыВерсионированияОбъектов.НеВерсионировать;
	
	Для Каждого Справочник Из Метаданные.Справочники Цикл
		Если Не ЗначениеЗаполнено(ЗагрузитьНастройкуВерсионированияПоОбъекту(Справочник.Имя)) Тогда
			ЗаписатьНастройкуВерсионированияПоОбъекту(Справочник.Имя,
			                                          НВСправочники);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Документ Из Метаданные.Документы Цикл
		Если ДокументПроводится(Документ.Имя) Тогда
			НВДокументы = Перечисления.ВариантыВерсионированияОбъектов.ВерсионироватьПриПроведении;
		Иначе
			НВДокументы = Перечисления.ВариантыВерсионированияОбъектов.ВерсионироватьВсегда;
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ЗагрузитьНастройкуВерсионированияПоОбъекту(Документ.Имя)) Тогда
			ЗаписатьНастройкуВерсионированияПоОбъекту(Документ.Имя,
			                                          НВДокументы);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Записывает настройку версионирования по объекту в регистр сведений
//
Процедура ЗаписатьНастройкуВерсионированияПоОбъекту(
                                  Объект,
                                  ВариантВерсионирования) Экспорт
	
	ВариантМВ = РегистрыСведений.НастройкаВерсионированияОбъектов.СоздатьМенеджерЗаписи();
	ВариантМВ.ТипОбъекта = Объект;
	ВариантМВ.Вариант = ВариантВерсионирования;
	ВариантМВ.Записать();
	
КонецПроцедуры

// Записывает настройку версионирования по объекту в регистр сведений
//
Функция ЗагрузитьНастройкуВерсионированияПоОбъекту(знач Объект) Экспорт
	
	ВариантМВ = РегистрыСведений.НастройкаВерсионированияОбъектов.СоздатьМенеджерЗаписи();
	ВариантМВ.ТипОбъекта = Объект;
	ВариантМВ.Прочитать();
	
	Возврат ВариантМВ.Вариант;
	
КонецФункции

