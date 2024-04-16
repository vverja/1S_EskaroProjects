// Формирует печатную форму заявки
//
Функция ПечатьЗаявки(МассивОбъектов, ОбъектыПечати)
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ЗаявкаНаРасходованиеСредств";
	
	Макет = ПолучитьМакет("ЗаявкаНаРасходованиеСредств");
	
	// печать производится на языке, указанном в настройках пользователя
	КодЯзыкаПечать = Локализация.ПолучитьЯзыкФормированияПечатныхФорм(УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "РежимФормированияПечатныхФорм"));
	Макет.КодЯзыкаМакета = КодЯзыкаПечать;
	
	ПервыйДокумент = Истина;
	
	Для каждого Ссылка Из МассивОбъектов Цикл
		
		Если НЕ ПервыйДокумент Тогда
			ТабДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		ПервыйДокумент = Ложь;
		
		НомерСтрокиНачало = ТабДокумент.ВысотаТаблицы + 1;
	
		Обл   = Макет.ПолучитьОбласть("Заголовок");
		
		// ШАПКА
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ЗаявкаНаРасходованиеСредствРазмещениеЗаявки.МестоРазмещения КАК МестоРазмещения,
		|	СУММА(ЗаявкаНаРасходованиеСредствРазмещениеЗаявки.СуммаПлатежа) КАК СуммаПлатежа
		|ИЗ
		|	Документ.ЗаявкаНаРасходованиеСредств.РазмещениеЗаявки КАК ЗаявкаНаРасходованиеСредствРазмещениеЗаявки
		|ГДЕ
		|	ЗаявкаНаРасходованиеСредствРазмещениеЗаявки.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ЗаявкаНаРасходованиеСредствРазмещениеЗаявки.МестоРазмещения
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Заявка.Дата КАК Дата,
		|	Заявка.Номер КАК Номер,
		|   Заявка.Организация КАК Организация,
		|	Заявка.Контрагент КАК Контрагент,
		|	Заявка.Контрагент.Представление КАК КонтрагентПредставление,
		|	Заявка.Получатель.Представление КАК ПолучательПредставление,
		|	Заявка.ДатаПогашенияАванса КАК ДатаПогашенияАванса,
		|	Заявка.ВидОперации КАК ВидОперации,
		|	Заявка.Проведен КАК Проведен,
		|	Заявка.ВалютаДокумента КАК ВалютаДокумента,
		|	Заявка.КурсДокумента КАК КурсДокумента,
		|	Заявка.КратностьДокумента КАК КратностьДокумента,
		|	Заявка.Номенклатура КАК Номенклатура,
		|	Заявка.ЦФО КАК ЦФО,
		|	Заявка.СтатьяОборотов КАК СтатьяОборотов,
		|	Заявка.Сценарий КАК Сценарий,
		|	Заявка.Сценарий.Валюта КАК ВалютаСценария,
		|	Заявка.Сценарий.Периодичность КАК ПериодичностьСценария,
		|	Заявка.Описание КАК Описание,
		|	Заявка.ДатаРасхода КАК ДатаРасхода,
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Заявка.РасчетныйДокумент) КАК РасчетныйДокумент,
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Заявка.Ссылка) КАК ПредставлениеДокумента
		|ИЗ
		|	Документ.ЗаявкаНаРасходованиеСредств КАК Заявка
		|ГДЕ
		|	Заявка.Ссылка = &Ссылка";

		РезультатЗапроса = Запрос.ВыполнитьПакет();
		ТабРазмещениеЗаявки = РезультатЗапроса[0].Выгрузить();
		
		Шапка = РезультатЗапроса[1].Выбрать();
		Шапка.Следующий();
		
		ЕстьРасчетыСКонтрагентами = УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(Шапка.ВидОперации);
		ЕстьРасчетыПоКредитам = УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(Шапка.ВидОперации);
		
		НаименованиеОперации = ПолучитьНаименованиеОперации(Шапка.ВидОперации, КодЯзыкаПечать);
		Обл.Параметры.ЗаголовокЗаявки = ОбщегоНазначения.СформироватьЗаголовокДокумента(Шапка, НаименованиеОперации, КодЯзыкаПечать);
		
		Обл.Параметры.Заполнить(Ссылка);
		
		Обл.Параметры.ФормаОплаты = Локализация.ПолучитьЛокализованныйСинонимОбъекта(Обл.Параметры.ФормаОплаты, КодЯзыкаПечать);
		
		ТабДокумент.Вывести(Обл);
		
		Если ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам Тогда
			Обл = Макет.ПолучитьОбласть("ЗаголовокРасчеты");
			Обл.Параметры.Контрагент = Шапка.КонтрагентПредставление;
			ТабДокумент.Вывести(Обл);
			
			Запрос=Новый Запрос;
			Запрос.Текст="ВЫБРАТЬ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.ДоговорКонтрагента КАК ДоговорКонтрагента,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Сделка КАК Сделка,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаПлатежа КАК СуммаПлатежа,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.ДоговорКонтрагента.ВалютаВзаиморасчетов КАК ВалютаВзаиморасчетов,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.КурсВзаиморасчетов КАК КурсВзаиморасчетов,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КАК СуммаВзаиморасчетов,
			|	ВЫБОР КОГДА НЕ((РасчетыСКонтрагентамиОстатки.СуммаВзаиморасчетовОстаток) ЕСТЬ NULL ) 
			|		ТОГДА 
			|			ВЫБОР КОГДА НЕ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.Проведен
			|			ТОГДА РасчетыСКонтрагентамиОстатки.СуммаВзаиморасчетовОстаток+ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов
			|			ИНАЧЕ РасчетыСКонтрагентамиОстатки.СуммаВзаиморасчетовОстаток КОНЕЦ
			|		ИНАЧЕ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КОНЕЦ КАК ТекущийДолг
			|ИЗ
			|	Документ.ЗаявкаНаРасходованиеСредств.РасшифровкаПлатежа КАК ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.РасчетыСКонтрагентами.Остатки КАК РасчетыСКонтрагентамиОстатки
			|		ПО ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.ДоговорКонтрагента = РасчетыСКонтрагентамиОстатки.ДоговорКонтрагента И ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Сделка = РасчетыСКонтрагентамиОстатки.Сделка
			|
			|ГДЕ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка = &Ссылка";
			
			Запрос.УстановитьПараметр("Ссылка", Ссылка);
			
			Результат=Запрос.Выполнить().Выбрать();
			
			Пока Результат.Следующий() Цикл
				
				Обл=Макет.ПолучитьОбласть("СтрокаРасчеты");
				Обл.Параметры.Заполнить(Результат);
				ТабДокумент.Вывести(Обл);
				
			КонецЦикла;
			
			Обл=Макет.ПолучитьОбласть("ПодвалРасчеты");
			ТабДокумент.Вывести(Обл);
			
		ИначеЕсли Шапка.ВидОперации = Перечисления.ВидыОперацийЗаявкиНаРасходование.ВыдачаДенежныхСредствПодотчетнику Тогда
			
			Обл=Макет.ПолучитьОбласть("ЗаголовокПодотчет");
			Обл.Параметры.Получатель = Шапка.ПолучательПредставление;
			Обл.Параметры.ТекстВыдачаФизЛицу=НСтр("ru='Выдача денежных средств под отчет';uk='Видача коштів під звіт'", КодЯзыкаПечать);
			Обл.Параметры.РасчетныйДокумент =  Шапка.РасчетныйДокумент;
			ТабДокумент.Вывести(Обл);
			
			Запрос=Новый Запрос;
			Запрос.Текст="ВЫБРАТЬ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.ВалютаВзаиморасчетовПодотчетника КАК ВалютаВзаиморасчетовПодотчетника,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.КурсВзаиморасчетов КАК КурсВзаиморасчетов,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КАК СуммаВзаиморасчетов,
			|	ВЫБОР КОГДА НЕ((ВзаиморасчетыСПодотчетнымиЛицамиОстатки.СуммаВзаиморасчетовОстаток) ЕСТЬ NULL ) 
			|		ТОГДА ВзаиморасчетыСПодотчетнымиЛицамиОстатки.СуммаВзаиморасчетовОстаток + ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов 
			|		ИНАЧЕ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КОНЕЦ КАК ТекущийДолг
			|ИЗ
			|	Документ.ЗаявкаНаРасходованиеСредств.РасшифровкаПлатежа КАК ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ВзаиморасчетыСПодотчетнымиЛицами.Остатки КАК ВзаиморасчетыСПодотчетнымиЛицамиОстатки
			|		ПО ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.Получатель = ВзаиморасчетыСПодотчетнымиЛицамиОстатки.ФизЛицо 
			|		И ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.ВалютаВзаиморасчетовПодотчетника = ВзаиморасчетыСПодотчетнымиЛицамиОстатки.Валюта 
			|		И ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.РасчетныйДокумент = ВзаиморасчетыСПодотчетнымиЛицамиОстатки.РасчетныйДокумент
			|
			|ГДЕ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка = &Ссылка";
			
			Запрос.УстановитьПараметр("Ссылка", Ссылка);
			
			Результат=Запрос.Выполнить().Выбрать();
			
			Если Результат.Следующий() Тогда
				
				Обл=Макет.ПолучитьОбласть("СтрокаПодотчет");
				Обл.Параметры.ДатаПогашенияАванса = Шапка.ДатаПогашенияАванса;
				Обл.Параметры.Заполнить(Результат);
				ТабДокумент.Вывести(Обл);
				
			КонецЕсли;
			
			Обл=Макет.ПолучитьОбласть("ПодвалПодотчет");
			ТабДокумент.Вывести(Обл);
			
		ИначеЕсли Шапка.ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.РасчетыПоКредитамИЗаймамСРаботниками Тогда
			
			Обл = Макет.ПолучитьОбласть("ЗаголовокПодотчет");
			Обл.Параметры.Получатель = Шапка.ПолучательПредставление;
			Обл.Параметры.ТекстВыдачаФизЛицу=НСтр("ru='Выдача денежных средств по договору займа';uk='Видача коштів за договором позики'",КодЯзыкаПечать);
			Обл.Параметры.РасчетныйДокумент = Шапка.РасчетныйДокумент;
			ТабДокумент.Вывести(Обл);
			
			Запрос=Новый Запрос;
			Запрос.Текст="ВЫБРАТЬ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.ВалютаВзаиморасчетовПодотчетника КАК ВалютаВзаиморасчетовПодотчетника,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.КурсВзаиморасчетов КАК КурсВзаиморасчетов,
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КАК СуммаВзаиморасчетов,
			|	ВЫБОР КОГДА НЕ((ПогашениеЗаймовРаботникамиОрганизацийОстатки.ФизЛицо) ЕСТЬ NULL ) 
			|		ТОГДА ПогашениеЗаймовРаботникамиОрганизацийОстатки.ОсновнойДолгОстаток 
			|				+ ПогашениеЗаймовРаботникамиОрганизацийОстатки.ПроцентыОстаток 
			|				+ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов 
			|		КОГДА НЕ((ПогашениеЗаймовРаботникамиОстатки.ФизЛицо) ЕСТЬ NULL ) 
			|		ТОГДА ПогашениеЗаймовРаботникамиОстатки.ОсновнойДолгОстаток 
			|				+ ПогашениеЗаймовРаботникамиОстатки.ПроцентыОстаток 
			|				+ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов 
			|		ИНАЧЕ ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.СуммаВзаиморасчетов КОНЕЦ КАК ТекущийДолг
			|ИЗ
			|	Документ.ЗаявкаНаРасходованиеСредств.РасшифровкаПлатежа КАК ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПогашениеЗаймовРаботниками.Остатки КАК ПогашениеЗаймовРаботникамиОстатки
			|		ПО ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.Получатель = ПогашениеЗаймовРаботникамиОстатки.ФизЛицо 
			|			И ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.РасчетныйДокумент = ПогашениеЗаймовРаботникамиОстатки.ДоговорЗайма
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПогашениеЗаймовРаботникамиОрганизаций.Остатки КАК ПогашениеЗаймовРаботникамиОрганизацийОстатки
			|		ПО ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.Получатель = ПогашениеЗаймовРаботникамиОрганизацийОстатки.ФизЛицо 
			|			И ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка.РасчетныйДокумент = ПогашениеЗаймовРаботникамиОрганизацийОстатки.ДоговорЗайма
			|
			|ГДЕ
			|	ЗаявкаНаРасходованиеСредствРасшифровкаПлатежа.Ссылка = &Ссылка";
			
			Запрос.УстановитьПараметр("Ссылка",Ссылка);
			
			Результат=Запрос.Выполнить().Выбрать();
			
			Если Результат.Следующий() Тогда
				
				Обл=Макет.ПолучитьОбласть("СтрокаПодотчет");
				Обл.Параметры.ДатаПогашенияАванса = Шапка.ДатаПогашенияАванса;
				Обл.Параметры.Заполнить(Результат);
				ТабДокумент.Вывести(Обл);
				
			КонецЕсли;
			
			Обл=Макет.ПолучитьОбласть("ПодвалПодотчет");
			ТабДокумент.Вывести(Обл);
			
		ИначеЕсли Шапка.ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ВыдачаДенежныхСредствКассеККМ Тогда
			
			Обл=Макет.ПолучитьОбласть("ЗаголовокВыдачаКассеККМ");
			Обл.Параметры.Получатель = Шапка.ПолучательПредставление;
			ТабДокумент.Вывести(Обл);
			
		КонецЕсли;
		
		Обл=Макет.ПолучитьОбласть("ЗаголовокРазмещениеЗаявки");
		
		Если ТабРазмещениеЗаявки.Количество() = 0 Тогда
			
			Обл.Параметры.ТекстРазмещениеЗаявки=НСтр("ru='Не размещено';uk='Не розміщено'",КодЯзыкаПечать);
			ТабДокумент.Вывести(Обл);
			
		Иначе
			
			Обл.Параметры.ТекстРазмещениеЗаявки=НСтр("ru='Таблица размещения';uk='Таблиця розміщення'",КодЯзыкаПечать);
			ТабДокумент.Вывести(Обл);
			
			Обл = Макет.ПолучитьОбласть("ШапкаРазмещениеЗаявки");
			ТабДокумент.Вывести(Обл);
			
			Для Каждого Строка Из ТабРазмещениеЗаявки Цикл
				
				Если Строка.МестоРазмещения=Неопределено Тогда
					Продолжить;
				ИначеЕсли ТипЗнч(Строка.МестоРазмещения)= Тип("ДокументСсылка.ПланируемоеПоступлениеДенежныхСредств") Тогда
					
					Обл=Макет.ПолучитьОбласть("СтрокаРазмещениеЗаявки");
					
					ОстатокКРазмещению=УправлениеДенежнымиСредствами.ПолучитьНеразмещенныйостаток(Строка.МестоРазмещения, Шапка.ДатаРасхода, Ссылка);
					
					Обл.Параметры.МестоРазмещения=Строка.МестоРазмещения;
					Обл.Параметры.СуммаПлатежа=Строка.СуммаПлатежа;
					Обл.Параметры.ТекущийОстаток=ОстатокКРазмещению-Строка.СуммаПлатежа;
					
				Иначе
					
					// Проверяем остаток доступных денежных средств
					Обл=Макет.ПолучитьОбласть("СтрокаРазмещениеЗаявки");
					
					СвободныйОстаток=УправлениеДенежнымиСредствами.ПолучитьСвободныйОстатокДС(Строка.МестоРазмещения, Шапка.ДатаРасхода, Ссылка);
					
					Обл.Параметры.МестоРазмещения=Строка.МестоРазмещения;
					Обл.Параметры.СуммаПлатежа=Строка.СуммаПлатежа;
					Обл.Параметры.ТекущийОстаток=СвободныйОстаток-Строка.СуммаПлатежа;
					
				КонецЕсли;
				
				ТабДокумент.Вывести(Обл);
				
			КонецЦикла;
			
			Обл=Макет.ПолучитьОбласть("ПодвалРазмещение");
			ТабДокумент.Вывести(Обл);
			
		КонецЕсли;
		
		Если НЕ ПустаяСтрока(Шапка.Описание) Тогда
			
			Обл=Макет.ПолучитьОбласть("ОписаниеЗаявки");
			Обл.Параметры.Описание = Шапка.Описание;
			ТабДокумент.Вывести(Обл);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Шапка.Сценарий) Тогда // Есть связь с бюджетированием
		
			Обл = Макет.ПолучитьОбласть("ЗаголовокБюджетирование");
			Обл.Параметры.Заполнить(Шапка);
			
			// Получение списка контролирующих сценариев для выбранного периода и измерений бюджетирования
			
			СтруктураПараметров = Новый Структура;
			СтруктураПараметров.Вставить("ЕстьРасчетыСКонтрагентами", ЕстьРасчетыСКонтрагентами);
			СтруктураПараметров.Вставить("ЕстьРасчетыПоКредитам", ЕстьРасчетыПоКредитам);
			СтруктураПараметров.Вставить("ВидОперации", Шапка.ВидОперации);
			СтруктураПараметров.Вставить("ДатаРасхода", Шапка.ДатаРасхода);
			ТабПроверкиОборотов = Бюджетирование.СформироватьТаблицуДляКонтроля(Ссылка, СтруктураПараметров);
			
			Для Каждого СтрокаПлатеж Из ТабПроверкиОборотов Цикл
				
				Запрос=Новый Запрос;
				
				Запрос.Текст="ВЫБРАТЬ
				|	УстановкаОграниченийПоБюджетам.КонтролирующийСценарий КАК КонтролирующийСценарий,
				|	УстановкаОграниченийПоБюджетам.СтатьяОборотов КАК СтатьяОборотов,
				|	УстановкаОграниченийПоБюджетам.ЦФО КАК ЦФО,
				|	УстановкаОграниченийПоБюджетам.Проект КАК Проект,
				|	УстановкаОграниченийПоБюджетам.Контрагент КАК Контрагент,
				|	УстановкаОграниченийПоБюджетам.Номенклатура КАК Номенклатура
				|ИЗ
				|	РегистрСведений.УстановкаОграниченийПоБюджетам КАК УстановкаОграниченийПоБюджетам
				|
				|ГДЕ
				|	УстановкаОграниченийПоБюджетам.Период = &Период И
				|	УстановкаОграниченийПоБюджетам.СтатьяОборотов = &СтатьяОборотов И
				|	УстановкаОграниченийПоБюджетам.Сценарий = &Сценарий И
				|	(УстановкаОграниченийПоБюджетам.ЦФО = &ЦФО ИЛИ УстановкаОграниченийПоБюджетам.ЦФО = &ПустойЦФО) И
				|	(УстановкаОграниченийПоБюджетам.Проект = &Проект ИЛИ УстановкаОграниченийПоБюджетам.Проект = &ПустойПроект) И
				|	(УстановкаОграниченийПоБюджетам.Контрагент = &Контрагент ИЛИ УстановкаОграниченийПоБюджетам.Контрагент = &ПустойКонтрагент) И
				|	(УстановкаОграниченийПоБюджетам.Номенклатура = &Номенклатура ИЛИ УстановкаОграниченийПоБюджетам.Номенклатура = Неопределено) И
				|	УстановкаОграниченийПоБюджетам.ИспользованиеКонтролируемогоЗначения = &ИспользованиеКонтролируемогоЗначения И
				|	УстановкаОграниченийПоБюджетам.ВидКонтролируемогоЗначения = &ВидКонтролируемогоЗначения";
				
				Запрос.УстановитьПараметр("Период", ОбщегоНазначения.ДатаНачалаПериода(Шапка.ДатаРасхода, Шапка.ПериодичностьСценария));
				Запрос.УстановитьПараметр("СтатьяОборотов", Шапка.СтатьяОборотов);
				Запрос.УстановитьПараметр("ИспользованиеКонтролируемогоЗначения", Перечисления.ИспользованиеКонтролируемыхЗначенийБюджетов.ПриИсполнении);
				Запрос.УстановитьПараметр("ВидКонтролируемогоЗначения", Перечисления.ВидыКонтролируемогоЗначенияБюджета.Ограничивающее);
				Запрос.УстановитьПараметр("Сценарий", Шапка.Сценарий);
				
				Запрос.УстановитьПараметр("ЦФО", Шапка.ЦФО);
				Запрос.УстановитьПараметр("ПустойЦФО",Новый(Тип("СправочникСсылка.Подразделения")));
				
				Запрос.УстановитьПараметр("Проект", СтрокаПлатеж.Проект);
				Запрос.УстановитьПараметр("ПустойПроект", Новый(Тип("СправочникСсылка.Проекты")));
				
				Запрос.УстановитьПараметр("Контрагент", Шапка.Контрагент);
				Запрос.УстановитьПараметр("ПустойКонтрагент",Новый(Тип("СправочникСсылка.Контрагенты")));
				
				Запрос.УстановитьПараметр("Номенклатура", Шапка.Номенклатура);
				
				ТабРезультата=Запрос.Выполнить().Выгрузить();
				
				Если ТабРезультата.Количество()=0 Тогда
					
					Продолжить;
					
				Иначе
					
					Обл.Параметры.НадписьКонтрольОборотов=НСтр("ru='Ограничения, установленные по обороту:';uk='Обмеження, установлені по обігу:'",КодЯзыкаПечать);
					ТабДокумент.Вывести(Обл);
					
					Обл = Макет.ПолучитьОбласть("ЗаголовокКонтроль");
					ТабДокумент.Вывести(Обл);
					
					ТабРезультата.Колонки.Добавить("СуммаСценарияИсполнение");
					ТабРезультата.Колонки.Добавить("Период");
					
					Для каждого СтрокаПроверки Из ТабРезультата Цикл
						
						Обл = Макет.ПолучитьОбласть("СтрокаКонтроль");
						
						ТекущийСценарий =?(СтрокаПроверки.КонтролирующийСценарий.Пустая(), Шапка.Сценарий, СтрокаПроверки.КонтролирующийСценарий);
						
						ДатаНачала = ОбщегоНазначения.ДатаНачалаПериода(Шапка.ДатаРасхода, ТекущийСценарий.Периодичность);
						ДатаКонца  = ОбщегоНазначения.ДатаКонцаПериода(ДатаНачала,ТекущийСценарий.Периодичность);
						
						КурсСценария = Бюджетирование.КурсВалютыПоСценарию(Шапка.ВалютаСценария, ДатаНачала, Шапка.Сценарий).Курс;
						КратностьСценария = Бюджетирование.КурсВалютыПоСценарию(Шапка.ВалютаСценария, ДатаНачала, Шапка.Сценарий).Кратность;
						
						Если ТабПроверкиОборотов.Колонки.Найти("СуммаУпр") = Неопределено Тогда
							
							СуммаСценария = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаПлатеж.СуммаПлатежа,
													Шапка.ВалютаДокумента, 
													Шапка.ВалютаСценария, 
													Шапка.КурсДокумента, 
													КурсСценария, 
													Шапка.КратностьДокумента,
													КратностьСценария);
							
						Иначе
							
							СуммаСценария = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(СтрокаПлатеж.СуммаУпр,,
													Шапка.ВалютаСценария,
													СтрокаПлатеж.КурсУпрУчета, 
													КурсСценария,
													СтрокаПлатеж.КратностьУпрУчета, 
													КратностьСценария);
							
						КонецЕсли;
						
						Запрос.Текст = "ВЫБРАТЬ
						|	СУММА(КонтролируемыеЗначенияБюджетовОбороты.СуммаСценарияКонтрольОборот) КАК СуммаКонтроль,
						|	СУММА(КонтролируемыеЗначенияБюджетовОбороты.СуммаСценарияИсполнениеОборот) КАК СуммаИсполнение
						|ИЗ
						|	РегистрНакопления.КонтролируемыеЗначенияБюджетов.Обороты(&ДатаНач, &ДатаКон, , 
						|					Контрагент = &Контрагент И 
						|					КонтролирующийСценарий=&КонтролирующийСценарий И
						|					Номенклатура=&Номенклатура И 
						|					Проект=&Проект И 
						|					СтатьяОборотов=&СтатьяОборотов И 
						|					Сценарий=&Сценарий И 
						|					ЦФО=&ЦФО И 
						|					ИспользованиеКонтролируемогоЗначения=&ИспользованиеКонтролируемогоЗначения
						|					) КАК КонтролируемыеЗначенияБюджетовОбороты";
						
						Запрос.УстановитьПараметр("ДатаНач", НачалоДня(ДатаНачала));
						Запрос.УстановитьПараметр("ДатаКон", КонецДня(ДатаНачала));
						Запрос.УстановитьПараметр("Контрагент", СтрокаПроверки.Контрагент);
						Запрос.УстановитьПараметр("КонтролирующийСценарий", СтрокаПроверки.КонтролирующийСценарий);
						Запрос.УстановитьПараметр("Номенклатура", СтрокаПроверки.Номенклатура);
						Запрос.УстановитьПараметр("Проект", СтрокаПроверки.Проект);
						Запрос.УстановитьПараметр("СтатьяОборотов", СтрокаПроверки.СтатьяОборотов);
						Запрос.УстановитьПараметр("Сценарий", Шапка.Сценарий);
						Запрос.УстановитьПараметр("ЦФО", СтрокаПроверки.ЦФО);
						Запрос.УстановитьПараметр("ИспользованиеКонтролируемогоЗначения",Перечисления.ИспользованиеКонтролируемыхЗначенийБюджетов.ПриИсполнении);
						
						СуммаКонтроль = 0;
						СуммаИсполнение = 0;
						
						Результат = Запрос.Выполнить();
						Выборка = Результат.Выбрать();
						Если Выборка.Следующий() И (НЕ Выборка["СуммаКонтроль"] = NULL) И (НЕ Выборка["СуммаИсполнение"]=NULL) Тогда
							Обл.Параметры.СуммаКонтроль = Выборка["СуммаКонтроль"];
							Обл.Параметры.СуммаИсполнение = Выборка["СуммаИсполнение"] + ?(НЕ Шапка.Проведен,СуммаСценария,0);
							Обл.Параметры.КонтролирующийСценарий = ТекущийСценарий;
							Обл.Параметры.ТекущийОстаток = Выборка["СуммаКонтроль"] - Выборка["СуммаИсполнение"]-?(НЕ Шапка.Проведен, СуммаСценария, 0);
							Обл.Параметры.Период = ОбщегоНазначения.ПолучитьПериодСтрокой(ДатаНачала,Строка(ТекущийСценарий.Периодичность), КодЯзыкаПечать);
							ТабДокумент.Вывести(Обл);
						КонецЕсли;
						
					КонецЦикла; 
					
				КонецЕсли;
				
			КонецЦикла;
			
			Обл=Макет.ПолучитьОбласть("ПодвалКонтроль");
				ТабДокумент.Вывести(Обл);

		КонецЕсли;	
				
	    Обл=Макет.ПолучитьОбласть("Подвал");
		ТабДокумент.Вывести(Обл);
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДокумент, НомерСтрокиНачало, ОбъектыПечати, Ссылка);
		
	КонецЦикла; 
	
	// Первую колонку не печатаем
	ТабДокумент.ОбластьПечати = ТабДокумент.Область(1,1,ТабДокумент.ВысотаТаблицы,ТабДокумент.ШиринаТаблицы);
	
	Возврат ТабДокумент;
	
КонецФункции // ПечатьЗаявки()
	
// Сформировать печатные формы объектов
//
// ВХОДЯЩИЕ:
//   МассивОбъектов  - Массив    - Массив ссылок на объекты которые нужно распечатать
//
// ИСХОДЯЩИЕ:
//   КоллекцияПечатныхФорм - Таблица значений - Сформированные табличные документы
//   ОшибкиПечати          - Список значений  - Ошибки печати  (значение - ссылка на объект, представление - текст ошибки)
//   ОбъектыПечати         - Список значений  - Объекты печати (значение - ссылка на объект, представление - имя области в которой был выведен объект)
//   ПараметрыВывода       - Структура        - Параметры сформированных табличных документов
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ПараметрыВывода.ДоступнаПечатьПоКомплектно = Истина;
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ПечатьЗаявки") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ПечатьЗаявки", "Заявка на расходование средствы", ПечатьЗаявки(МассивОбъектов, ОбъектыПечати));
	КонецЕсли;
	
КонецПроцедуры

// Возвращает наименование операции документа на требуемом языке
//
// Возвращаемое значение:
//   Наименование операции документа
//
Функция ПолучитьНаименованиеОперации(ВидОперации, КодЯзыка = "ru")
	
	Если ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ОплатаПоставщику Тогда
  		Возврат ""+	НСтр("ru='Оплата поставщику';uk='Оплата постачальникові'",КодЯзыка);
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ВозвратДенежныхСредствПокупателю  Тогда  	
      Возврат ""+	НСтр("ru='Возврат денежных средств покупателю';uk='Повернення коштів покупцеві'",КодЯзыка);
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ВыдачаДенежныхСредствПодотчетнику  Тогда	
			Возврат ""+	НСтр("ru='Выдача денежных средств подотчетнику';uk='Видача коштів підзвітникові'",КодЯзыка);
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ВыдачаДенежныхСредствКассеККМ Тогда	
  		Возврат ""+	НСтр("ru='Выдача денежных средств в кассу ККМ';uk='Видача коштів у касу ККМ'",КодЯзыка);
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.РасчетыПоКредитамИЗаймамСКонтрагентами Тогда
			Возврат ""+	НСтр("ru='Расчеты по кредитам и займам с контрагентами';uk='Розрахунки по кредитах і позикам з контрагентами'",КодЯзыка);
	ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.РасчетыПоКредитамИЗаймамСРаботниками Тогда
  		Возврат ""+	НСтр("ru='Расчеты по кредитам и займам с работниками';uk='Розрахунки по кредитах і позикам з працівниками'",КодЯзыка);
  ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ПеречислениеНалога Тогда
  		Возврат ""+	НСтр("ru='Перечисление налога';uk='Перерахування податку'",КодЯзыка);
  ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ПеречислениеЗП Тогда
    	Возврат ""+	НСтр("ru='Выплата заработной платы';uk='Виплата заробітної плати'",КодЯзыка);
  ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ПрочийРасходДенежныхСредств Тогда
  		Возврат ""+	НСтр("ru='Прочий расход денежных средств';uk='Інша витрата коштів'",КодЯзыка);
  ИначеЕсли ВидОперации=Перечисления.ВидыОперацийЗаявкиНаРасходование.ПрочиеРасчетыСКонтрагентами Тогда
  		Возврат ""+	НСтр("ru='Прочие расчеты с контрагентами';uk='Інші розрахунки з контрагентами'",КодЯзыка);
  Иначе
     Возврат "";
  КонецЕсли;
	
КонецФункции // ПолучитьНаименованиеОперации()

