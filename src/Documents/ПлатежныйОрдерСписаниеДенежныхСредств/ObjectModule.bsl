Перем мУдалятьДвижения;

// Текущие курс и кратность валюты документа для расчетов
Перем КурсДокумента Экспорт;
Перем КратностьДокумента Экспорт;

Перем мВалютаРегламентированногоУчета Экспорт;

// Хранят группировочные признаки вида операции
Перем ЕстьРасчетыСКонтрагентами Экспорт;
Перем ЕстьРасчетыПоКредитам Экспорт;

Перем ТаблицаПлатежейУпр;

//Определение периода движений документа
Перем ДатаДвижений;
Перем РасчетыВозврат;
Перем мСтруктураПараметровДенежныхСредств;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
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
			Возврат;
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	Возврат Новый Структура;
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

#КонецЕсли


//Заполняет сумму документа и расшифровку платежа по расчетному документу
 //
Процедура ЗаполнитьПоРасчетномуДокументуУпр() Экспорт
	
	Организация=РасчетныйДокумент.Организация;
	СчетОрганизации=РасчетныйДокумент.СчетОрганизации;
	
	Контрагент=РасчетныйДокумент.Контрагент;
	СчетКонтрагента=РасчетныйДокумент.СчетКонтрагента;
	
	ВалютаДокумента=РасчетныйДокумент.ВалютаДокумента;
	СтруктураКурсаДокумента   = МодульВалютногоУчета.ПолучитьКурсВалюты(ВалютаДокумента,Дата);
	КурсДокумента      = СтруктураКурсаДокумента.Курс;
	КратностьДокумента = СтруктураКурсаДокумента.Кратность;
	
	ВидОперацииДокумент=РасчетныйДокумент.ВидОперации;
	
	Если ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ВозвратДенежныхСредствПокупателю 
	 ИЛИ ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ВозвратДенежныхСредствПокупателю Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ВозвратДенежныхСредствПокупателю;
	ИначеЕсли ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ОплатаПоставщику 
		  ИЛИ ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ОплатаПоставщику Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ОплатаПоставщику;
	ИначеЕсли ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПеречислениеНалога 
		  ИЛИ ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПеречислениеНалога Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеНалога;
	ИначеЕсли ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПрочееСписаниеБезналичныхДенежныхСредств 
		  ИЛИ ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПрочееСписаниеБезналичныхДенежныхСредств Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочееСписаниеБезналичныхДенежныхСредств;
	ИначеЕсли ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам 
		  ИЛИ ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.РасчетыПоКредитамИЗаймамСКонтрагентами Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.РасчетыПоКредитамИЗаймам;
	ИначеЕсли ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПокупкаПродажаВалюты Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПокупкаПродажаВалюты;
	ИначеЕсли ВидОперацииДокумент=Перечисления.ВидыОперацийППИсходящее.ПрочиеРасчетыСКонтрагентами Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочиеРасчетыСКонтрагентами;
	ИначеЕсли ВидОперацииДокумент=Перечисления.ВидыОперацийППИсходящее.ПеречислениеДенежныхСредствПодотчетнику Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеДенежныхСредствПодотчетнику;
		ФизЛицо = РасчетныйДокумент.ФизЛицо;
	Иначе	
		ВидОперации=ВидОперацииДокумент;
	КонецЕсли;
		
	ЕстьРасчетыСКонтрагентами=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);
	
	ОтраженоВОперУчете=РасчетныйДокумент.ОтраженоВОперУчете;
	ОтражатьВБухгалтерскомУчете=РасчетныйДокумент.ОтражатьВБухгалтерскомУчете;
		
	Если ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам ИЛИ ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеДенежныхСредствПодотчетнику Тогда
		
	    //По расшифровке платежа 
		
			ТекстЗапроса="ВЫБРАТЬ
		             |	ДенежныеСредстваКСписаниюОстатки.ДокументСписания,
		             |	ДенежныеСредстваКСписаниюОстатки.СуммаОстаток,
					 |	ДенежныеСредстваКСписаниюОстатки.СтатьяДвиженияДенежныхСредств,
		             |	РасчетныйДокумент.ДоговорКонтрагента,
		             |	РасчетныйДокумент.Сделка,
		             |	РасчетныйДокумент.Ссылка.СуммаДокумента КАК СуммаДокумента,
		             |	РасчетныйДокумент.СуммаПлатежа,
					 |	РасчетныйДокумент.КурсВзаиморасчетов,
		             |	РасчетныйДокумент.КратностьВзаиморасчетов,
		             |	РасчетныйДокумент.СуммаВзаиморасчетов,
		             |	РасчетныйДокумент.СтавкаНДС,
		             |	РасчетныйДокумент.СуммаНДС,
		             |	РасчетныйДокумент.ЗаТару,
		             |	РасчетныйДокумент.СчетУчетаРасчетовСКонтрагентом,
		             |	РасчетныйДокумент.СчетУчетаРасчетовПоАвансам,
					 |	РасчетныйДокумент.Проект 				 
		             |ИЗ
		             |	РегистрНакопления.ДенежныеСредстваКСписанию.Остатки(, ДокументСписания=&РасчетныйДокумент) КАК ДенежныеСредстваКСписаниюОстатки
		             |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ."+РасчетныйДокумент.Метаданные().Имя+".РасшифровкаПлатежа КАК РасчетныйДокумент
		             |		ПО ДенежныеСредстваКСписаниюОстатки.ДокументСписания = РасчетныйДокумент.Ссылка";
					 
		Запрос=Новый Запрос;
		Запрос.Текст=ТекстЗапроса;
		Запрос.УстановитьПараметр("РасчетныйДокумент",РасчетныйДокумент);
		
		Результат=Запрос.Выполнить().Выбрать();
		
		Пока Результат.Следующий() Цикл
			
			СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
			
			ЗаполнитьЗначенияСвойств(СтрокаПлатеж, Результат);
			
			КоэффициентПересчета=?(Результат.СуммаДокумента=0,0,Результат.СуммаОстаток/Результат.СуммаДокумента);
			
			СтрокаПлатеж.СуммаПлатежа		=Результат.СуммаПлатежа*КоэффициентПересчета;
			СтрокаПлатеж.СуммаВзаиморасчетов=Результат.СуммаВзаиморасчетов*КоэффициентПересчета;
			СтрокаПлатеж.СуммаНДС			=Результат.СуммаНДС*КоэффициентПересчета;
			
		КонецЦикла;
		
		СуммаДокумента=РасшифровкаПлатежа.Итог("СуммаПлатежа");

	Иначе
		
		ТекстЗапроса="ВЫБРАТЬ
					 |	ЕСТЬNULL(ДенежныеСредстваКСписаниюОстатки.СуммаОстаток, 0) КАК СуммаОстаток
		             |ИЗ
		             |	РегистрНакопления.ДенежныеСредстваКСписанию.Остатки(, ДокументСписания=&РасчетныйДокумент) КАК ДенежныеСредстваКСписаниюОстатки";
					 
		Запрос=Новый Запрос;
		Запрос.Текст=ТекстЗапроса;
		Запрос.УстановитьПараметр("РасчетныйДокумент",РасчетныйДокумент);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Выборка.Следующий();
		
		СуммаДокумента = Выборка.СуммаОстаток;
			
		СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
		СтрокаПлатеж.СуммаПлатежа=СуммаДокумента;
			
		СтатьяДвиженияДенежныхСредств = РасчетныйДокумент.СтатьяДвиженияДенежныхСредств;
		
		СчетУчетаРасчетовСКонтрагентом=РасчетныйДокумент.СчетУчетаРасчетовСКонтрагентом;
		СубконтоДт1=РасчетныйДокумент.СубконтоДт1;
	    СубконтоДт2=РасчетныйДокумент.СубконтоДт2;
		СубконтоДт3=РасчетныйДокумент.СубконтоДт3;
		Если ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеНалога Тогда
			Если РасчетныйДокумент.Метаданные().Реквизиты.Найти("ПериодРегистрацииНал") <> Неопределено Тогда
				ПериодРегистрации = РасчетныйДокумент.ПериодРегистрацииНал;
			КонецЕсли;
			ПеречислениеНалогов.Загрузить(РасчетныйДокумент.ПеречислениеНалогов.Выгрузить());
		КонецЕсли;	
		СтатьяДвиженияДенежныхСредств=РасчетныйДокумент.СтатьяДвиженияДенежныхСредств;
		
	КонецЕсли;	
	
	Если ТипЗнч(РасчетныйДокумент) = Тип("ДокументСсылка.ПлатежноеПоручениеИсходящее") Тогда
		Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПокупкаПродажаВалюты Тогда
			Если СчетУчетаРасчетовСКонтрагентом.ВидыСубконто.Количество() > 0 Тогда
				СубконтоДт1 = Новый(СчетУчетаРасчетовСКонтрагентом.ВидыСубконто[0].ВидСубконто.ТипЗначения.Типы()[0]);
			КонецЕсли;
			СубконтоДт1=РасчетныйДокумент.Контрагент;
		КонецЕсли;	
	КонецЕсли;	
		
КонецПроцедуры // ЗаполнитьПоРасчетномуДокументуУпр()

// Проверяет установленные курсы валют документа перед пересчетом сумм
// Нулевые курсы устанавливаются в 1
//
Процедура ПроверкаКурсовВалют(СтрокаПлатеж)

	КурсДокумента=?(КурсДокумента=0,1, КурсДокумента);
	КратностьДокумента=?(КратностьДокумента=0,1, КратностьДокумента);
	СтрокаПлатеж.КурсВзаиморасчетов=?(СтрокаПлатеж.КурсВзаиморасчетов=0,1,СтрокаПлатеж.КурсВзаиморасчетов);
	СтрокаПлатеж.КратностьВзаиморасчетов=?(СтрокаПлатеж.КратностьВзаиморасчетов=0,1,СтрокаПлатеж.КратностьВзаиморасчетов);

КонецПроцедуры // ПроверкаКурсовВалют()


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Формирует структуру полей, обязательных для заполнения при отражении фактического
// движения средств по банку.
//
// Возвращаемое значение:
//   СтруктураОбязательныхПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейОплата()

	СтруктураПолей=Новый Структура;
	СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");
	СтруктураПолей.Вставить("СуммаДокумента");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплата()

// Формирует структуру полей, обязательных для заполнения при отражении операции во 
// взаиморасчетах
// Возвращаемое значение:
//   СтруктурахПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейРасчеты()

	Если ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам Тогда
		
		СтруктураПолей= Новый Структура("Организация,
		|Контрагент, Ответственный");
		СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");

	Иначе

		СтруктураПолей= Новый Структура("Организация, СуммаДокумента,Ответственный");
		СтруктураПолей.Вставить("СчетОрганизации","Не указан банковский счет организации!");

	КонецЕсли;

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплата()

// Проверяет значение, необходимое при проведении
Процедура ПроверитьЗначение(Значение, Отказ, Заголовок, ИмяРеквизита)
	
	Если НЕ ЗначениеЗаполнено(Значение) Тогда 
		ОбщегоНазначения.СообщитьОбОшибке("Не заполнено значение реквизита """+ИмяРеквизита+"""",Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ПроверитьЗначение()

// Проверяет заполнение табличной части документа
//
Процедура ПроверитьЗаполнениеТЧ(Отказ, Заголовок)
	
	Для Каждого Платеж Из РасшифровкаПлатежа Цикл
		
		ПроверитьЗначение(Платеж.ДоговорКонтрагента,Отказ, Заголовок,"Договор");
		ПроверитьЗначение(Платеж.СуммаВзаиморасчетов,Отказ, Заголовок,"Сумма взаиморасчетов");
		
		Если Не Отказ Тогда
			
			// Сделка должна быть заполнена, если учет взаиморасчетов ведется по заказам.
			Если Платеж.ДоговорКонтрагента.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоЗаказам Тогда
				
				ТекстСделка=?(УправлениеДенежнымиСредствами.ОпределитьПараметрыВыбораСделки(ВидОперации).ТипЗаказа="ЗаказПокупателя","Заказ покупателя","Заказ поставщику");
				ПроверитьЗначение(Платеж.Сделка,Отказ, Заголовок,ТекстСделка);
				
				Если Отказ Тогда
				
					Сообщить("По договору "+Строка(Платеж.ДоговорКонтрагента)+" установлен способ ведения взаиморасчетов ""по заказам""! 
					|Заполните поле """+ТекстСделка+"""!");
					
				КонецЕсли;
				
			ИначеЕсли Платеж.ДоговорКонтрагента.ВедениеВзаиморасчетов = Перечисления.ВедениеВзаиморасчетовПоДоговорам.ПоСчетам Тогда
				
				ТекстСделка=?(УправлениеДенежнымиСредствами.ОпределитьПараметрыВыбораСделки(ВидОперации).ТипЗаказа="ЗаказПокупателя","Счет покупателя","Счет поставщику");
				ПроверитьЗначение(Платеж.Сделка,Отказ, Заголовок,ТекстСделка);

				Если Отказ Тогда
					Сообщить("По договору "+Строка(Платеж.ДоговорКонтрагента)+" установлен способ ведения взаиморасчетов ""по счетам""! 
					|Заполните поле """+ТекстСделка+"""!");
				КонецЕсли;
						
			КонецЕсли;
			
			Если ЗначениеЗаполнено(Организация) 
				И Организация <> Платеж.ДоговорКонтрагента.Организация Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Выбран договор контрагента, не соответствующий организации, указанной в документе!", Отказ, Заголовок);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // ПроверитьЗаполнениеТЧ

// Формирует движения по регистрам
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//  Режим 					  - режим проведения документа
//
Процедура ДвиженияПоРегистрам(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	ДвиженияПоРегистрамУпр(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента);
    ДвиженияПоРегистрамРегл(РежимПроведения,Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если ЕстьРасчетыСКонтрагентами или ЕстьРасчетыПоКредитам Тогда
		ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
	КонецЕсли; 

КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияПоРегистрамУпр(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	мСтруктураПараметровДенежныхСредств.Вставить("РасчетыВозврат",            РасчетыВозврат);
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыСКонтрагентами", ЕстьРасчетыСКонтрагентами);
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыПоКредитам",     ЕстьРасчетыПоКредитам);
	мСтруктураПараметровДенежныхСредств.Вставить("БанковскийСчетКасса",       СчетОрганизации);
	мСтруктураПараметровДенежныхСредств.Вставить("ДатаДвижений",              ДатаДвижений);
	мСтруктураПараметровДенежныхСредств.Вставить("ПоРасчетномуДокументу",     ЗначениеЗаполнено(РасчетныйДокумент));
	
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПереводНаДругойСчет Тогда
		мСтруктураПараметровДенежныхСредств.Вставить("БанковскийСчетКассаПолучатель", СчетКонтрагента);
		мСтруктураПараметровДенежныхСредств.Вставить("ВидДенежныхСредствПолучатель",  Перечисления.ВидыДенежныхСредств.Безналичные);
	КонецЕсли;
	
	УправлениеДенежнымиСредствами.ПровестиСписаниеДенежныхСредствУпр(
		СтруктураШапкиДокумента, мСтруктураПараметровДенежныхСредств, ТаблицаПлатежейУпр, Движения, Отказ, Заголовок);

КонецПроцедуры

Процедура ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	Если НЕ (Оплачено И ОтраженоВОперУчете) Тогда
		Возврат;
	КонецЕсли;
	
	ВидДвижения = ВидДвиженияНакопления.Расход;
	Если СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ВозвратДенежныхСредствПоставщиком Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоПриобретению;
	ИначеЕсли СтруктураШапкиДокумента.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ОплатаПокупателя Тогда
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.ПоРеализации;
	Иначе
		ВидРасчетовПоОперации = перечисления.ВидыРасчетовСКонтрагентами.Прочее;
	КонецЕсли;
	СтруктураШапкиДокумента.Вставить("РежимПроведения", РежимПроведения);
	
	УправлениеВзаиморасчетами.ОтражениеОплатыВРегистреОперативныхРасчетовПоДокументам(СтруктураШапкиДокумента, ДатаДвижений, "РасшифровкаПлатежа", ВидРасчетовПоОперации, ВидДвижения, Движения, Отказ, Заголовок);

КонецПроцедуры

Процедура ДвиженияПоРегистрамРегл(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыСКонтрагентами",	ЕстьРасчетыСКонтрагентами);
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыПоКредитам",		ЕстьРасчетыПоКредитам);
	мСтруктураПараметровДенежныхСредств.Вставить("РежимПроведения",				РежимПроведения);
	мСтруктураПараметровДенежныхСредств.Вставить("ДатаДвижений",				ДатаДвижений);
	мСтруктураПараметровДенежныхСредств.Вставить("СчетОрганизации",				СчетОрганизации);
	мСтруктураПараметровДенежныхСредств.Вставить("Оплачено",					Оплачено);
	
	УправлениеДенежнымиСредствами.ПровестиСписаниеДенежныхСредствРегл(
		СтруктураШапкиДокумента, мСтруктураПараметровДенежныхСредств, ТаблицаПлатежейУпр, Движения, Отказ, Заголовок);

КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаУпр(Отказ, Режим, Заголовок)
	
	Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеДенежныхСредствПодотчетнику Тогда
		Если НЕ ЗначениеЗаполнено(ФизЛицо) Тогда
			Сообщить(Заголовок+"
			|Не указано подотчетное лицо");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
		
	Если ОтраженоВОперУчете И (ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам) Тогда
			
			ПроверитьЗаполнениеТЧ(Отказ, Заголовок);
			
	КонецЕсли;
	
	Если ОтраженоВОперУчете И ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочееСписаниеБезналичныхДенежныхСредств И ОтражатьПоЗатратам Тогда
		СтруктураОбязательныхПолей = Новый Структура("СтатьяЗатрат");
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
		
		Если ЗначениеЗаполнено(СтатьяЗатрат) Тогда
			Если Не (СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.ПроизводственныеРасходы ИЛИ
					 СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.АдминистративныеРасходы ИЛИ
				     СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.ОбщепроизводственныеРасходы ИЛИ
				     СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.Прочие ИЛИ
				     СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.ПрочиеОперационныеРасходы ИЛИ
				     СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.РасходыНаСбыт ИЛИ
					 СтатьяЗатрат.ХарактерЗатрат = Перечисления.ХарактерЗатрат.ТранспортноЗаготовительныеРасходы) 
			Тогда
			     ОбщегоНазначения.СообщитьОбОшибке("При указании статьи затрат с характером затрат " + СтатьяЗатрат.ХарактерЗатрат + " движения в затратных регистрах по УУ не будут отражены", Отказ, Заголовок);
			КонецЕсли;
		КонецЕсли;
    КонецЕсли;
	
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаРегл(Отказ, Режим, Заголовок, СтруктураШапкиДокумента)
	
	Если ОтражатьВБухгалтерскомУчете Тогда
		
		СтруктураПолей = Новый Структура("СчетУчетаРасчетовСКонтрагентом");
		
		Если ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПеречислениеНалога
			ИЛИ ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПрочееСписаниеБезналичныхДенежныхСредств Тогда

			ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект,СтруктураПолей, Отказ, Заголовок);
			
		ИначеЕсли ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПеречислениеДенежныхСредствПодотчетнику Тогда
			
			УправлениеДенежнымиСредствами.ПроверитьСоответствиеРаботникаОрганизации(ФизЛицо, Организация, Дата, Отказ, Заголовок);
			
		ИначеЕсли ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам Тогда

			ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "РасшифровкаПлатежа", СтруктураПолей, Отказ, Заголовок);
			
		КонецЕсли;
		
		Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочееСписаниеБезналичныхДенежныхСредств И ОтражатьПоЗатратам Тогда
			ХарактерЗатрат = УправлениеЗатратами.ПолучитьХарактерЗатратПоСчетуЗатрат(СчетУчетаРасчетовСКонтрагентом, СтатьяЗатрат);
			
			Если НЕ (ХарактерЗатрат = Перечисления.ХарактерЗатрат.ПроизводственныеРасходы ИЛИ
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.ПрочиеОперационныеРасходы ИЛИ 
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.Прочие ИЛИ
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.РасходыНаСбыт ИЛИ
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.ТранспортноЗаготовительныеРасходы ИЛИ 
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.ОбщепроизводственныеРасходы ИЛИ 
				ХарактерЗатрат = Перечисления.ХарактерЗатрат.АдминистративныеРасходы) И ЗначениеЗаполнено(СчетУчетаРасчетовСКонтрагентом)
			Тогда
				ОбщегоНазначения.СообщитьОбОшибке("При указании счета затрат " + СчетУчетаРасчетовСКонтрагентом + " с характером затрат " + ХарактерЗатрат + " движения в затратных регистрах (бух. учет, нал. учет) не будут отражены",  Отказ, Заголовок);
			КонецЕсли;
		КонецЕсли; 	
			
		Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочееСписаниеБезналичныхДенежныхСредств И ЗначениеЗаполнено(СчетУчетаРасчетовСКонтрагентом) И СчетУчетаРасчетовСКонтрагентом.НалоговыйУчет Тогда 
		
			
			НалоговыйУчет.ПроверитьЗаполнениеНалоговыхНазначений(
				СтруктураШапкиДокумента, 
				Неопределено,      // Неопределено - в случае проверки шапки документа
				Неопределено,      // Неопределено - в случае проверки шапки документа
				Отказ, 
				Заголовок, 
				"ОтражениеЗатрат", // ВидОперации
				Истина,            // ОтражатьПоЗатратам,
				"СчетУчетаРасчетовСКонтрагентом", // ИмяРеквизитаСчетЗатрат
				"СубконтоДт"       // ИмяРеквизитаСубконтоЗатрат
			);
			
		КонецЕсли; 
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПодготовитьСтруктуруШапкиДокумента(СтруктураШапкиДокумента, Заголовок)

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке      = УправлениеЗапасами.СформироватьДеревоПолейЗапросаПоШапке();
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВедениеВзаиморасчетов"                         , "ВедениеВзаиморасчетов");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВалютаВзаиморасчетов"                          , "ВалютаВзаиморасчетов");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "Организация"                       			, "ДоговорОрганизация");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВидДоговора"                       			, "ВидДоговора");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика"     , "ВедениеУчетаПоПроектам"                     , "ВедениеУчетаПоПроектам");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Организация"         , "ОтражатьВРегламентированномУчете"              , "ОтражатьВРегламентированномУчете");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);
	СтруктураШапкиДокумента.Вставить("ОтражатьВУправленческомУчете",Истина); // Банковские документы всегда отражаются в упр. учете
	
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами ИЛИ
		ВидОперации = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам Тогда
		
		КурсДокумента      = РасшифровкаПлатежа[0].КурсВзаиморасчетов;
		КратностьДокумента = РасшифровкаПлатежа[0].КратностьВзаиморасчетов;

	Иначе	
		СтруктураКурсаДокумента = МодульВалютногоУчета.ПолучитьКурсВалюты(ВалютаДокумента,Дата);
		
		КурсДокумента      = СтруктураКурсаДокумента.Курс;
		КратностьДокумента = СтруктураКурсаДокумента.Кратность;
	КонецЕсли;
	СтруктураШапкиДокумента.Вставить("КурсДокумента"		, КурсДокумента);
	СтруктураШапкиДокумента.Вставить("КратностьДокумента"	, КратностьДокумента);

	ДатаДвижений=УправлениеДенежнымиСредствами.ПолучитьДатуДвижений(Дата,ДатаОплаты);
	СтруктураШапкиДокумента.Вставить("ДатаОплаты",ДатаДвижений);
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если Не Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(Основание)) ИЛИ Основание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеПоручениеИсходящее") Тогда
		ВидОперацииДокумент=Основание.ВидОперации;
		Если ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПереводНаДругойСчет
		 Или ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПрочиеРасчетыСКонтрагентами
		 Или ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.ПеречислениеЗП
		 Или ВидОперацииДокумент = Перечисления.ВидыОперацийППИсходящее.РасчетыПоКредитамИЗаймамСРаботниками Тогда
			Сообщить("Платежный ордер не вводится на основании Документа с указанным видом операции."); 
			Возврат;
		КонецЕсли;
	ИначеЕсли ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеТребованиеПоручениеПолученное") Или ТипЗнч(Основание) = Тип("ДокументСсылка.АккредитивПереданный") Или ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеТребованиеПолученное") Тогда
		ВидОперацииДокумент=Основание.ВидОперации;
		Если ВидОперацииДокумент = Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами Тогда
			Сообщить("Платежный ордер не вводится на основании Документа с указанным видом операции."); 
			Возврат;
		КонецЕсли;
		
	КонецЕсли;

	Если Основание.Метаданные().Реквизиты.Найти("Оплачено") <> Неопределено Тогда
		
		Если Основание.Оплачено Тогда
			Сообщить("Платежный ордер не вводится на основании документов, уже исполненных банком.");
			Возврат;
		КонецЕсли;
		
		РасчетныйДокумент = Основание.Ссылка;
		ДокументОснование = РасчетныйДокумент;
		
		ЗаполнитьПоРасчетномуДокументуУпр();
		
		
	Иначе
		
		УправлениеДенежнымиСредствами.ЗаполнитьРасходПоОснованию(ЭтотОбъект, Основание, УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный"));
		
	КонецЕсли;

	Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный");
	ДокументОснование  = Основание;
	
КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаПроведения(Отказ, Режим)
	Перем Заголовок, СтруктураШапкиДокумента;
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	ПодготовитьСтруктуруШапкиДокумента(СтруктураШапкиДокумента, Заголовок);
	
	ЕстьРасчетыСКонтрагентами=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);
	РасчетыВозврат = УправлениеДенежнымиСредствами.НаправленияДвиженияДляДокументаДвиженияДенежныхСредствУпр(ВидОперации);
	
	Если ЗначениеЗаполнено(РасчетныйДокумент)
		И РасчетныйДокумент.Оплачено 
		Тогда
		ОбщегоНазначения.СообщитьОбОшибке(Строка(РасчетныйДокумент)+" уже оплачен полностью. Проведение отменено.", Отказ, Заголовок);
	КонецЕсли;
	
	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	Если НЕ РасшифровкаПлатежа.Итог("СуммаПлатежа")= СуммаДокумента Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не совпадают сумма документа и ее расшифровка.",Отказ, Заголовок);
	КонецЕсли;
	
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейОплата(), Отказ, Заголовок);
	
	Если ОтраженоВОперУчете И Не ВидОперации=Перечисления.ВидыОперацийСписаниеБезналичныхДенежныхСредств.ПереводНаДругойСчет Тогда
		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейРасчеты(), Отказ, Заголовок);
	КонецЕсли;
	
	Если Не Отказ Тогда
		
		ТаблицаПлатежейУпр = УправлениеДенежнымиСредствами.ПолучитьТаблицуПлатежейУпр(ДатаДвижений,ВалютаДокумента,Ссылка, "ПлатежныйОрдерСписаниеДенежныхСредств");
		
		ПроверитьЗаполнениеДокументаУпр(Отказ, Режим, Заголовок);
		ПроверитьЗаполнениеДокументаРегл(Отказ, Режим, Заголовок, СтруктураШапкиДокумента);
		
	КонецЕсли;
	
	//Проверим на возможность проведения в БУ и НУ
	Если ОтражатьВБухгалтерскомУчете тогда
		Для каждого СтрокаОплаты из РасшифровкаПлатежа Цикл
			УправлениеВзаиморасчетами.ПроверкаВозможностиПроведенияВ_БУ_НУ(СтрокаОплаты.ДоговорКонтрагента, СтруктураШапкиДокумента.ВалютаДокумента,
			СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете,
			мВалютаРегламентированногоУчета, Истина,Отказ, Заголовок,"Строка "+СтрокаОплаты.НомерСтроки+" - ");
		КонецЦикла;
	КонецЕсли;
	
	// Движения по документу
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;
		
	Если НЕ Отказ 
		И ЗначениеЗаполнено(РасчетныйДокумент) 
		И НЕ РасчетныйДокумент.ЧастичнаяОплата 
		Тогда
		
			ИзменяемыйДокумент=РасчетныйДокумент.ПолучитьОбъект();
			Попытка
				ИзменяемыйДокумент.Заблокировать();
			Исключение
				Сообщить("Не удалось заблокировать документ "+ИзменяемыйДокумент+". Возможно, его форма открыта");
				Отказ = истина;
				Возврат;
			КонецПопытки;
			ИзменяемыйДокумент.Разблокировать();

			ИзменяемыйДокумент.ЧастичнаяОплата=Истина;
			ИзменяемыйДокумент.Записать(РежимЗаписиДокумента.Запись);
													
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	// Проверим необходимость снятия флага частичной оплаты у расчетного документа
	
	Если Не РасчетныйДокумент=Неопределено Тогда	
		
		Запрос=Новый Запрос;
		Запрос.Текст="ВЫБРАТЬ
		|	ПлатежныйОрдерСписаниеДенежныхСредств.Ссылка
		|ИЗ
		|	Документ.ПлатежныйОрдерСписаниеДенежныхСредств КАК ПлатежныйОрдерСписаниеДенежныхСредств
		|
		|ГДЕ
		|	ПлатежныйОрдерСписаниеДенежныхСредств.Ссылка <> &Ссылка И
		|  ПлатежныйОрдерСписаниеДенежныхСредств.РасчетныйДокумент=&РасчетныйДокумент И
		|	ПлатежныйОрдерСписаниеДенежныхСредств.Проведен";
		
		Запрос.УстановитьПараметр("Ссылка",Ссылка);
		Запрос.УстановитьПараметр("РасчетныйДокумент",РасчетныйДокумент);
		
		Результат=Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			
			ИзменяемыйДокумент=РасчетныйДокумент.ПолучитьОбъект();
			Попытка
				ИзменяемыйДокумент.Заблокировать();
			Исключение
				Сообщить("Не удалось заблокировать документ "+ИзменяемыйДокумент+". Возможно, его форма открыта");
				Отказ = истина;
				Возврат;
			КонецПопытки;
			ИзменяемыйДокумент.Разблокировать();
			ИзменяемыйДокумент.ЧастичнаяОплата=Ложь;
			ИзменяемыйДокумент.Записать(РежимЗаписиДокумента.Запись);
			
		КонецЕсли;
				
	КонецЕсли;

КонецПроцедуры

// Процедура - обработчик события "ПриЗаписи"
//
Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	Если ВидОперации <> Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПеречислениеДенежныхСредствПодотчетнику Тогда
		Если ЗначениеЗаполнено(ФизЛицо) Тогда
			ФизЛицо = Справочники.ФизическиеЛица.ПустаяСсылка();
		КонецЕсли;
	КонецЕсли;

	Если ОтражатьВБухгалтерскомУчете И ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерСписание.ПрочееСписаниеБезналичныхДенежныхСредств Тогда
		
		НалоговыйУчет.ЗаполнитьНалоговыеНазначенияВШапкеПередЗаписьюДокумента(
			ЭтотОбъект,
			"СчетУчетаРасчетовСКонтрагентом",    // ИмяРеквизитаСчетЗатрат
			"СубконтоДт" // ИмяРеквизитаСубконто
		);
		
	КонецЕсли;

	мУдалятьДвижения = НЕ ЭтоНовый();

КонецПроцедуры // ПередЗаписью

// Процедура - обработчик события "ПриКопировании" объекта.
//
Процедура ПриКопировании(ОбъектКопирования)
	
	ДокументОснование = Неопределено;

КонецПроцедуры

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");

мСтруктураПараметровДенежныхСредств = Новый Структура;
мСтруктураПараметровДенежныхСредств.Вставить("ВидДенежныхСредств", Перечисления.ВидыДенежныхСредств.Безналичные);
