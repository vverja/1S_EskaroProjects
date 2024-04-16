Перем мУдалятьДвижения;

// Текущие курс и кратность валюты документа для расчетов
Перем КурсДокумента Экспорт;
Перем КратностьДокумента Экспорт;

Перем мВалютаРегламентированногоУчета Экспорт;

// Хранят группировочные признаки вида операции
Перем ЕстьРасчетыСКонтрагентами Экспорт;
Перем ЕстьРасчетыПоКредитам Экспорт;

// Хранит таблицу, использующуюся при проведении документа
Перем ТаблицаПлатежейУпр;

//Определение периода движений документа
Перем ДатаДвижений;
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
	
	Организация		=РасчетныйДокумент.Организация;
	СчетОрганизации	=РасчетныйДокумент.СчетОрганизации;
	
	Контрагент		=РасчетныйДокумент.Контрагент;
	СчетКонтрагента	=РасчетныйДокумент.СчетКонтрагента;
	
	ВалютаДокумента			= РасчетныйДокумент.ВалютаДокумента;
	СтруктураКурсаДокумента = МодульВалютногоУчета.ПолучитьКурсВалюты(ВалютаДокумента,Дата);
	КурсДокумента      		= СтруктураКурсаДокумента.Курс;
	КратностьДокумента 		= СтруктураКурсаДокумента.Кратность;
	
	Если РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ВозвратДенежныхСредствПоставщиком
	 ИЛИ РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийППВходящее.ВозвратДенежныхСредствПоставщиком Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ВозвратДенежныхСредствПоставщиком;
	ИначеЕсли РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ОплатаПокупателя 
		  ИЛИ РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийППВходящее.ОплатаПокупателя Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ОплатаПокупателя;
	ИначеЕсли РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПрочееПоступлениеБезналичныхДенежныхСредств 
		  ИЛИ РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийППВходящее.ПрочееПоступлениеБезналичныхДенежныхСредств Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПрочееПоступлениеБезналичныхДенежныхСредств;
	ИначеЕсли РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам 
		  ИЛИ РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийППВходящее.РасчетыПоКредитамИЗаймам Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.РасчетыПоКредитамИЗаймам;
	ИначеЕсли РасчетныйДокумент.ВидОперации = Перечисления.ВидыОперацийППВходящее.ПокупкаПродажаВалюты Тогда
		ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПокупкаПродажаВалюты;
	КонецЕсли; 
	
	ЕстьРасчетыСКонтрагентами	=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам		=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);
	
	Если РасчетныйДокумент.Метаданные().Реквизиты.Найти("ОтраженоВОперУчете") <> Неопределено Тогда
		ОтраженоВОперУчете=РасчетныйДокумент.ОтраженоВОперУчете;
	ИНаче
		ОтраженоВОперУчете=РасчетныйДокумент.ОтражатьВУправленческомУчете;
	КонецЕсли;	
	ОтражатьВБухгалтерскомУчете = РасчетныйДокумент.ОтражатьВБухгалтерскомУчете;
		
	Если ЕстьРасчетыСКонтрагентами ИЛИ ЕстьРасчетыПоКредитам Тогда
	
		ТекстЗапроса="ВЫБРАТЬ
		             |	ДенежныеСредстваКПолучениюОстатки.ДокументПолучения,
		             |	ДенежныеСредстваКПолучениюОстатки.СуммаОстаток,
					 |	ДенежныеСредстваКПолучениюОстатки.СтатьяДвиженияДенежныхСредств,
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
		             |	РегистрНакопления.ДенежныеСредстваКПолучению.Остатки(, ДокументПолучения=&РасчетныйДокумент) КАК ДенежныеСредстваКПолучениюОстатки
		             |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ."+РасчетныйДокумент.Метаданные().Имя+".РасшифровкаПлатежа КАК РасчетныйДокумент
		             |		ПО ДенежныеСредстваКПолучениюОстатки.ДокументПолучения = РасчетныйДокумент.Ссылка";
					 
		Запрос=Новый Запрос;
		Запрос.Текст=ТекстЗапроса;
		Запрос.УстановитьПараметр("РасчетныйДокумент",РасчетныйДокумент);
		
		Результат=Запрос.Выполнить().Выбрать();
		
		Пока Результат.Следующий() Цикл
			
			СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
			
			СтрокаПлатеж.ДоговорКонтрагента		=Результат.ДоговорКонтрагента;
			СтрокаПлатеж.Сделка					=Результат.Сделка;
			СтрокаПлатеж.КурсВзаиморасчетов		=Результат.КурсВзаиморасчетов;
			СтрокаПлатеж.КратностьВзаиморасчетов=Результат.КратностьВзаиморасчетов;
			СтрокаПлатеж.СтавкаНДС				=Результат.СтавкаНДС;
			СтрокаПлатеж.ЗаТару					=Результат.ЗаТару;
			СтрокаПлатеж.СчетУчетаРасчетовПоАвансам		=Результат.СчетУчетаРасчетовПоАвансам;
			СтрокаПлатеж.СчетУчетаРасчетовСКонтрагентом	=Результат.СчетУчетаРасчетовСКонтрагентом;
			СтрокаПлатеж.СтатьяДвиженияДенежныхСредств	=Результат.СтатьяДвиженияДенежныхСредств;
			СтрокаПлатеж.Проект=Результат.Проект;
			
			КоэффициентПересчета=?(Результат.СуммаДокумента=0,0,Результат.СуммаОстаток/Результат.СуммаДокумента);
			
			СтрокаПлатеж.СуммаПлатежа		=Результат.СуммаПлатежа*КоэффициентПересчета;
			СтрокаПлатеж.СуммаВзаиморасчетов=Результат.СуммаВзаиморасчетов*КоэффициентПересчета;
			СтрокаПлатеж.СуммаНДС			=Результат.СуммаНДС*КоэффициентПересчета;
			
		КонецЦикла;
		
		СуммаДокумента=РасшифровкаПлатежа.Итог("СуммаПлатежа");
		
	Иначе
		
		ТекстЗапроса="ВЫБРАТЬ
		             |	ДенежныеСредстваКПолучениюОстатки.СуммаОстаток
		             |ИЗ
		             |	РегистрНакопления.ДенежныеСредстваКПолучению.Остатки(, ДокументПолучения=&РасчетныйДокумент) КАК ДенежныеСредстваКПолучениюОстатки";
					 
		Запрос=Новый Запрос;
		Запрос.Текст=ТекстЗапроса;
		Запрос.УстановитьПараметр("РасчетныйДокумент",РасчетныйДокумент);
		
		Результат=Запрос.Выполнить().Выбрать();
		
		Если Результат.Следующий() Тогда
			
			СуммаДокумента=Результат.СуммаОстаток;
			
			СтрокаПлатеж=РасшифровкаПлатежа.Добавить();
			СтрокаПлатеж.СуммаПлатежа=СуммаДокумента;
			
		КонецЕсли;
		
		СчетУчетаРасчетовСКонтрагентом=РасчетныйДокумент.СчетУчетаРасчетовСКонтрагентом;
		СубконтоКт1=РасчетныйДокумент.СубконтоКт1;
	    СубконтоКт2=РасчетныйДокумент.СубконтоКт2;
		СубконтоКт3=РасчетныйДокумент.СубконтоКт3;
		СтатьяДвиженияДенежныхСредств=РасчетныйДокумент.СтатьяДвиженияДенежныхСредств;
		
	КонецЕсли;
	
	Если ТипЗнч(РасчетныйДокумент) = Тип("ДокументСсылка.ПлатежноеПоручениеВходящее") Тогда
		Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПокупкаПродажаВалюты Тогда
			Если СчетУчетаРасчетовСКонтрагентом.ВидыСубконто.Количество() > 0 Тогда
				СубконтоКт1 = Новый(СчетУчетаРасчетовСКонтрагентом.ВидыСубконто[0].ВидСубконто.ТипЗначения.Типы()[0]);
			КонецЕсли;
			СубконтоКт1=РасчетныйДокумент.Контрагент;
		КонецЕсли;	
	КонецЕсли;	
	
КонецПроцедуры // ЗаполнитьПоРасчетномуДокументуУпр()

// Формирует структуру полей, обязательных для заполнения при отражении фактического
// движения средств по банку.
//
// Возвращаемое значение:
//   СтруктураОбязательныхПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейОплатаУпр()

	СтруктураПолей=Новый Структура;
	СтруктураПолей.Вставить("СчетОрганизации");
	СтруктураПолей.Вставить("СуммаДокумента");

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейОплатаУпр()

// Формирует структуру полей, обязательных для заполнения при отражении операции во 
// взаиморасчетах
// Возвращаемое значение:
//   СтруктурахПолей   – структура для проверки
//
Функция СтруктураОбязательныхПолейРасчетыУпр()

	Если ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПрочееПоступлениеБезналичныхДенежныхСредств Тогда
		СтруктураПолей= Новый Структура("Организация,СчетОрганизации, Ответственный");
	Иначе
		 СтруктураПолей= Новый Структура("Организация,СчетОрганизации, Контрагент, Ответственный");
	КонецЕсли;

	Возврат СтруктураПолей;

КонецФункции // СтруктураОбязательныхПолейРасчетыУпр()

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
	ДвиженияПоРегистрамРегл(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
	
	Если ЕстьРасчетыСКонтрагентами или ЕстьРасчетыПоКредитам Тогда
		ДвиженияПоРегистрамОперативныхВзаиморасчетов(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента);
	КонецЕсли; 
КонецПроцедуры // ДвиженияПоРегистрам()

Процедура ДвиженияПоРегистрамУпр(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента)
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыСКонтрагентами", ЕстьРасчетыСКонтрагентами);
	мСтруктураПараметровДенежныхСредств.Вставить("ЕстьРасчетыПоКредитам",     ЕстьРасчетыПоКредитам);
	мСтруктураПараметровДенежныхСредств.Вставить("БанковскийСчетКасса",       СчетОрганизации);
	мСтруктураПараметровДенежныхСредств.Вставить("ДатаДвижений",              ДатаДвижений);
	мСтруктураПараметровДенежныхСредств.Вставить("ПоРасчетномуДокументу",     НЕ РасчетныйДокумент = Неопределено);
	
	УправлениеДенежнымиСредствами.ПровестиПоступлениеДенежныхСредствУпр(
		СтруктураШапкиДокумента, мСтруктураПараметровДенежныхСредств, ТаблицаПлатежейУпр, Движения, Отказ, Заголовок);
	
	Если ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПоступлениеОплатыПоПлатежнымКартам Тогда
		
		// Подготовим структуру таблицы для отражения затрат.
		ТаблицаЗатрат = УправлениеЗатратами.СформироватьТаблицуЗатрат();
		
		// Добавим строку в таблицу затрат.
		НоваяСтрока = ТаблицаЗатрат.Добавить();
		НоваяСтрока.Подразделение 			= СтруктураШапкиДокумента.ПодразделениеЗатраты;
		НоваяСтрока.СтатьяЗатрат 			= СтруктураШапкиДокумента.СтатьяЗатрат;
		НоваяСтрока.НоменклатурнаяГруппа 	= СтруктураШапкиДокумента.НоменклатурнаяГруппа;
		НоваяСтрока.Проект 					= ТаблицаПлатежейУпр[0].Проект;
		НоваяСтрока.Сумма 					= СтруктураШапкиДокумента.СуммаУслуг;
		
		УправлениеЗатратами.ДвиженияПоПрочимЗатратам(
			СтруктураШапкиДокумента,
			ТаблицаЗатрат
		);
		
	КонецЕсли;
	
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

Процедура ДвиженияПоРегистрамРегл(РежимПроведения, Отказ, Заголовок,СтруктураШапкиДокумента)

	мСтруктураПараметровДенежныхСредствРегл = Новый Структура;
	мСтруктураПараметровДенежныхСредствРегл.Вставить("ЕстьРасчетыСКонтрагентами",	ЕстьРасчетыСКонтрагентами);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("ЕстьРасчетыПоКредитам",		ЕстьРасчетыПоКредитам);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("РежимПроведения",				РежимПроведения);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("ДатаДвижений",				ДатаДвижений);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("СчетОрганизации",				СчетОрганизации);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("Оплачено",					Оплачено);
	мСтруктураПараметровДенежныхСредствРегл.Вставить("ВидДенежныхСредств", 			Перечисления.ВидыДенежныхСредств.Безналичные);
	
	УправлениеДенежнымиСредствами.ПровестиПоступлениеДенежныхСредствРегл(
		СтруктураШапкиДокумента, мСтруктураПараметровДенежныхСредствРегл, ТаблицаПлатежейУпр, Движения, Отказ, Заголовок);
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаУпр(Отказ, Заголовок)

	Если НЕ РасшифровкаПлатежа.Итог("СуммаПлатежа")= СуммаДокумента Тогда
		Сообщить(Заголовок+" 
		|не совпадают сумма документа и ее расшифровка.");

		Отказ = Истина;

	КонецЕсли;

	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейОплатаУпр(), Отказ, Заголовок);
	Если ОтраженоВОперУчете ИЛИ (ОтражатьВБухгалтерскомУчете И Оплачено) Тогда

		ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолейРасчетыУпр(), Отказ, Заголовок);
		
		Если НЕ (ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПрочееПоступлениеБезналичныхДенежныхСредств			
			ИЛИ ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПокупкаПродажаВалюты) Тогда
			
			ПроверитьЗаполнениеТЧ(Отказ, Заголовок);
			
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ПроверитьЗаполнениеДокументаРегл(Отказ, Заголовок, СтруктураШапкиДокумента)

	Если ОтражатьВБухгалтерскомУчете Тогда
		
		СтруктураПолей = Новый Структура("СчетУчетаРасчетовСКонтрагентом");
		
		Если ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПрочееПоступлениеБезналичныхДенежныхСредств Тогда
			
			
			ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект,СтруктураПолей, Отказ, Заголовок);
			
			НалоговыйУчет.ПроверитьЗаполнениеНалоговыхНазначений(
				СтруктураШапкиДокумента, 
				Неопределено,      // Неопределено - в случае проверки шапки документа
				Неопределено,      // Неопределено - в случае проверки шапки документа
				Отказ, 
				Заголовок, 
				"ОтражениеЗатрат", // ВидОперации
				Истина,            // ОтражатьПоЗатратам,
				"СчетУчетаРасчетовСКонтрагентом", // ИмяРеквизитаСчетЗатрат
				"СубконтоКт"       // ИмяРеквизитаСубконтоЗатрат
			);
			
			
		ИначеЕсли ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПокупкаПродажаВалюты Тогда

			ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект,СтруктураПолей, Отказ, Заголовок);
			
		Иначе

			Если ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ОплатаПокупателя
			ИЛИ ВидОперации=Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ВозвратДенежныхСредствПоставщиком Тогда
				СтруктураПолей.Вставить("СчетУчетаРасчетовПоАвансам");
			КонецЕсли;
			ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "РасшифровкаПлатежа", СтруктураПолей, Отказ, Заголовок);
			
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента)

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке      = УправлениеЗапасами.СформироватьДеревоПолейЗапросаПоШапке();
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВедениеВзаиморасчетов"                         , "ВедениеВзаиморасчетов");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВалютаВзаиморасчетов"                          , "ВалютаВзаиморасчетов");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "Организация"                       			, "ДоговорОрганизация");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорКонтрагента"  , "ВидДоговора"                       			, "ВидДоговора");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика"     , "ВедениеУчетаПоПроектам"                     , "ВедениеУчетаПоПроектам");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Организация"         , "ОтражатьВРегламентированномУчете"              , "ОтражатьВРегламентированномУчете");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"           , "ВалютаУправленческогоУчета"             		, "ВалютаУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"           , "КурсВалютыУправленческогоУчета"         		, "КурсВалютыУправленческогоУчета");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);
	СтруктураШапкиДокумента.Вставить("ОтражатьВУправленческомУчете",Истина); // Банковские документы всегда отражаются в упр. учете
	
	Если ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами ИЛИ
		ВидОперации = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.РасчетыПоКредитамИЗаймам Тогда
		
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
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если Не Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(Основание)) ИЛИ Основание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ПланируемоеПоступлениеДенежныхСредств") Тогда
		ВидОперацииДокумент=Основание.ВидОперации;
		Если ВидОперацииДокумент = Перечисления.ВидыОперацийПланируемоеПоступлениеДС.ПрочиеРасчетыСКонтрагентами Тогда
			Сообщить("Платежный ордер не вводится на основании Платежного Документа с указанным видом операции."); 
			Возврат;
		КонецЕсли;
	ИначеЕсли ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеТребованиеВыставленное") Или ТипЗнч(Основание) = Тип("ДокументСсылка.АккредитивПолученный") Или ТипЗнч(Основание) = Тип("ДокументСсылка.ПлатежноеТребованиеПоручениеВыставленное") Тогда
		ВидОперацииДокумент=Основание.ВидОперации;
		Если ВидОперацииДокумент = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПрочиеРасчетыСКонтрагентами
		 Или ВидОперацииДокумент = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПоступлениеОплатыПоПлатежнымКартам
		 Или ВидОперацииДокумент = Перечисления.ВидыОперацийПоступлениеБезналичныхДенежныхСредств.ПоступлениеОплатыПоБанковскимКредитам Тогда
			Сообщить("Платежный ордер не вводится на основании Платежного Документа с указанным видом операции."); 
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
		
		УправлениеДенежнымиСредствами.ЗаполнитьПриходПоОснованию(ЭтотОбъект, Основание, УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "ОсновнойОтветственный"));
		
	КонецЕсли;

КонецПроцедуры // ОбработкаЗаполнения()

Процедура ОбработкаПроведения(Отказ, Режим)

	Перем Заголовок, СтруктураШапкиДокумента;
	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;
	
	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента);
	
	Если (ЗначениеЗаполнено(РасчетныйДокумент)) И РасчетныйДокумент.Оплачено Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Документ: "+Строка(РасчетныйДокумент)+" уже оплачен полностью. Проведение отменено.",Отказ, Заголовок);
	КонецЕсли;
	
	ЕстьРасчетыСКонтрагентами=УправлениеДенежнымиСредствами.ЕстьРасчетыСКонтрагентами(ВидОперации);
	ЕстьРасчетыПоКредитам=УправлениеДенежнымиСредствами.ЕстьРасчетыПоКредитам(ВидОперации);

	// Документ должен принадлежать хотя бы к одному виду учета (управленческий, бухгалтерский, налоговый)
	ОбщегоНазначения.ПроверитьПринадлежностьКВидамУчета(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	ТаблицаПлатежейУпр=УправлениеДенежнымиСредствами.ПолучитьТаблицуПлатежейУпр(ДатаДвижений,ВалютаДокумента,Ссылка, "ПлатежныйОрдерПоступлениеДенежныхСредств");
	
	ПроверитьЗаполнениеДокументаУпр(Отказ, Заголовок);
	ПроверитьЗаполнениеДокументаРегл(Отказ, Заголовок, СтруктураШапкиДокумента);

	Если ЕстьРасчетыСКонтрагентами или ЕстьРасчетыПоКредитам Тогда
		
		//Проверим на возможность проведения в БУ и НУ
		Если СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете тогда
			Для каждого СтрокаОплаты из РасшифровкаПлатежа Цикл
				УправлениеВзаиморасчетами.ПроверкаВозможностиПроведенияВ_БУ_НУ(СтрокаОплаты.ДоговорКонтрагента, СтруктураШапкиДокумента.ВалютаДокумента,
				СтруктураШапкиДокумента.ОтражатьВБухгалтерскомУчете,
				мВалютаРегламентированногоУчета, Истина,Отказ, Заголовок,"Строка "+СтрокаОплаты.НомерСтроки+" - ");
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
	// Движения по документу
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;
	
	Если (Не РасчетныйДокумент=Неопределено) И (Не Отказ) И (Не РасчетныйДокумент.ЧастичнаяОплата) Тогда
		
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
		ИзменяемыйДокумент.Оплачено=Ложь;
		ИзменяемыйДокумент.ДатаОплаты='00010101';
		
		ИзменяемыйДокумент.Записать(РежимЗаписиДокумента.Запись);
		
	КонецЕсли;

КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	// Проверим необходимость снятия флага частичной оплаты у расчетного документа
	
	Если Не РасчетныйДокумент=Неопределено Тогда
		
		Запрос=Новый Запрос;
		Запрос.Текст="ВЫБРАТЬ
		             |	ПлатежныйОрдерПоступлениеДенежныхСредств.Ссылка
		             |ИЗ
		             |	Документ.ПлатежныйОрдерПоступлениеДенежныхСредств КАК ПлатежныйОрдерПоступлениеДенежныхСредств
		             |
		             |ГДЕ
		             |	ПлатежныйОрдерПоступлениеДенежныхСредств.Ссылка <> &Ссылка И
					 |  ПлатежныйОрдерПоступлениеДенежныхСредств.РасчетныйДокумент=&РасчетныйДокумент И
		             |	ПлатежныйОрдерПоступлениеДенежныхСредств.Проведен";
		
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
	
	Если ОтражатьВБухгалтерскомУчете И ВидОперации = Перечисления.ВидыОперацийПлатежныйОрдерПоступление.ПрочееПоступлениеБезналичныхДенежныхСредств Тогда
		
		НалоговыйУчет.ЗаполнитьНалоговыеНазначенияВШапкеПередЗаписьюДокумента(
			ЭтотОбъект,
			"СчетУчетаРасчетовСКонтрагентом",    // ИмяРеквизитаСчетЗатрат
			"СубконтоКт" // ИмяРеквизитаСубконто
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
