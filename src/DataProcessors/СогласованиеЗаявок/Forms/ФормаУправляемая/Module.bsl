////////////////////////////////////////////////////////////////////////////////
// ЗАЯВКИ

&НаКлиенте
Функция ПолучитьТекущуюСтрокуСписка()
	
	ТекущаяСтрока = Элементы.Список.ТекущаяСтрока;
	Если ТекущаяСтрока = Неопределено 
		ИЛИ ТипЗнч(ТекущаяСтрока) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
		
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ТекущаяСтрока;
	
КонецФункции // 

&НаКлиенте
Функция ПолучитьИмяФормыПоВидуОперации(ВидОперации)
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
	ИмяФормыПоВидуОперации = "ФормаОбъекта";
	#Иначе
	Если ВидОперации = ВидОперацииОплатаПоставщику 
		ИЛИ ВидОперации = ВидОперацииВозвратДенежныхСредствПокупателю
		ИЛИ ВидОперации = ВидОперацииПрочиеРасчетыСКонтрагентами Тогда
		
		ИмяФормыПоВидуОперации = "Форма.РасчетыСКонтрагентами";
		
	ИначеЕсли ВидОперации = ВидОперацииВыдачаДенежныхСредствПодотчетнику Тогда
		ИмяФормыПоВидуОперации = "Форма.РасчетыСПодотчетнымиЛицами";
		
	ИначеЕсли ВидОперации = ВидОперацииПрочийРасходДенежныхСредств Тогда
		ИмяФормыПоВидуОперации = "Форма.ПрочийРасходДенежныхСредств";
		
	Иначе
		ИмяФормыПоВидуОперации = "ФормаОбъекта";
	КонецЕсли; 
	#КонецЕсли
	
	Возврат "Документ.ЗаявкаНаРасходованиеСредств." + ИмяФормыПоВидуОперации;
	
КонецФункции // 

&НаКлиенте
Процедура ОткрытьФормуВыбранногоДокумента()

	ТекущаяСтрока = ПолучитьТекущуюСтрокуСписка();
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	ПолноеИмяФормы = ПолучитьИмяФормыПоВидуОперации(ТекущиеДанные.ВидОперации);
	
	ПараметрыФормы = Новый Структура("Ключ", ТекущиеДанные.Ссылка);
	ОткрытьФорму(ПолноеИмяФормы, ПараметрыФормы);
	
КонецПроцедуры //

&НаКлиенте
Процедура ИзменитьСтатусЗаявок(НовоеСостояние)

	Объект.ЗаявкиНаРасходованиеСредств.Очистить();
	
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	
	Для Каждого ИндексСтроки ИЗ ВыделенныеСтроки Цикл
		Если ТипЗнч(ИндексСтроки) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			Продолжить;
		КонецЕсли;
		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(ИндексСтроки);
		
		СтрокаТабличнойЧасти = Объект.ЗаявкиНаРасходованиеСредств.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТабличнойЧасти, ДанныеСтроки);
		
		СтрокаТабличнойЧасти.Пометка          = Истина;
		СтрокаТабличнойЧасти.Заявка           = ДанныеСтроки.Ссылка;
		СтрокаТабличнойЧасти.ТекущееСостояние = ДанныеСтроки.Состояние;
	КонецЦикла;
	
	Если Объект.ЗаявкиНаРасходованиеСредств.Количество() = 0 Тогда
		Предупреждение(НСтр("ru = 'Не выбрано ни одной заявки'"));
		Возврат;
	КонецЕсли;	
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", Объект);
	ПараметрыФормы.Вставить("НовоеСостояние", НовоеСостояние);
	ПараметрыФормы.Вставить("Заявки", Объект.ЗаявкиНаРасходованиеСредств);
	
	СвойстваОбъекта = Новый Структура;
	СвойстваОбъекта.Вставить("ТекущийПользователь",  Объект.ТекущийПользователь);
	СвойстваОбъекта.Вставить("ПроизвольныйОтчет",    Объект.ПроизвольныйОтчет);
	СвойстваОбъекта.Вставить("СохраненнаяНастройка", Объект.СохраненнаяНастройка);
	
	ПараметрыФормы.Вставить("СвойстваОбъекта",  СвойстваОбъекта);
	
	ОткрытьФорму("Обработка.СогласованиеЗаявок.Форма.ИзменениеСостоянияЗаявокУправляемая", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ОткрытьФормуВыбранногоДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломИзменения(Элемент, Отказ)
	
	Отказ = Истина;
	ОткрытьФормуВыбранногоДокумента();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// КОМАНДЫ

&НаКлиенте
Процедура Отклонить(Команда)
	
	ИзменитьСтатусЗаявок(СостоянияОбъектовОтклонен);
	
КонецПроцедуры

&НаКлиенте
Процедура Отложить(Команда)
	
	ИзменитьСтатусЗаявок(СостоянияОбъектовОтложен);
	
КонецПроцедуры

&НаКлиенте
Процедура Согласовать(Команда)
	
	ИзменитьСтатусЗаявок(СостоянияОбъектовСогласован);
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаОтчета(Команда)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПроизвольныйОтчет", Объект.ПроизвольныйОтчет);
	ПараметрыФормы.Вставить("СохраненнаяНастройка", Объект.СохраненнаяНастройка);
	
	РезультатНастройки = ОткрытьФормуМодально("Обработка.СогласованиеЗаявок.Форма.НастройкаОтчета", ПараметрыФормы);
	Если РезультатНастройки = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Объект.ПроизвольныйОтчет = РезультатНастройки.ПроизвольныйОтчет;
	Объект.СохраненнаяНастройка   = РезультатНастройки.СохраненнаяНастройка;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ФОРМА

&НаСервере
Функция ПолучитьЭтапыСогласованияПользователя()
	
	СписокЭтапов = Новый Массив;
	
	Запрос = Новый Запрос;
	
	ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	МаршрутыСогласованияСогласующиеЛица.Ссылка КАК ЭтапСогласования
	               |ИЗ
	               |	Справочник.МаршрутыСогласования.СогласующиеЛица КАК МаршрутыСогласованияСогласующиеЛица
	               |ГДЕ
	               |	МаршрутыСогласованияСогласующиеЛица.Пользователь = &ТекПользователь
	               |";
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("ТекПользователь", Объект.ТекущийПользователь);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СписокЭтапов.Добавить(Выборка.ЭтапСогласования);
	КонецЦикла;
	
	Возврат СписокЭтапов
	
КонецФункции // 

&НаСервере
Функция ПолучитьЭтапыМаршрутовВКоторыхУчаствуетПользователь(ЭтапыСогласования)
	
	СписокЭтапов = Новый Массив;
	
	Запрос = Новый Запрос;
	
	ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	МаршрутыСогласования.Ссылка КАК ЭтапСогласования
	               |ИЗ
	               |	Справочник.МаршрутыСогласования КАК МаршрутыСогласования
	               |ГДЕ
	               |	МаршрутыСогласования.Ссылка В ИЕРАРХИИ (&ЭтапыСогласования)";
	 
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("ТекПользователь", Объект.ТекущийПользователь);
	Запрос.УстановитьПараметр("ЭтапыСогласования", ЭтапыСогласования);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		СписокЭтапов.Добавить(Выборка.ЭтапСогласования);
	КонецЦикла;
	
	Возврат СписокЭтапов
	
КонецФункции // 

&НаСервере
Процедура ВосстановитьНастройкиОтборов(ДанныеОтбора)
	
	Список.Отбор.Элементы.Очистить();
	
	Если ДанныеОтбора = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТиповыеОтчеты.СкопироватьЭлементы(Список.Отбор, ДанныеОтбора);

КонецПроцедуры

// В процедуре инициализируются значения констант формы
// Константы используются при выполнении модуля формы
//
&НаСервере
Процедура УстановитьЗначенияКонстантФормы()
	
	ВидОперацииОплатаПоставщику                  = Перечисления.ВидыОперацийЗаявкиНаРасходование.ОплатаПоставщику;
	ВидОперацииВозвратДенежныхСредствПокупателю  = Перечисления.ВидыОперацийЗаявкиНаРасходование.ВозвратДенежныхСредствПокупателю;
	ВидОперацииПрочиеРасчетыСКонтрагентами       = Перечисления.ВидыОперацийЗаявкиНаРасходование.ПрочиеРасчетыСКонтрагентами;
	ВидОперацииВыдачаДенежныхСредствПодотчетнику = Перечисления.ВидыОперацийЗаявкиНаРасходование.ВыдачаДенежныхСредствПодотчетнику;
	ВидОперацииПрочийРасходДенежныхСредств       = Перечисления.ВидыОперацийЗаявкиНаРасходование.ПрочийРасходДенежныхСредств;
	
	СостоянияОбъектовСогласован = Перечисления.СостоянияОбъектов.Согласован;
	СостоянияОбъектовОтклонен   = Перечисления.СостоянияОбъектов.Отклонен;
	СостоянияОбъектовОтложен    = Перечисления.СостоянияОбъектов.Отложен;
	
	Объект.ТекущийПользователь = глЗначениеПеременной("глТекущийПользователь");
	
КонецПроцедуры //

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьЗначенияКонстантФормы();
	
	ЭтапыСогласования = ПолучитьЭтапыСогласованияПользователя();
	СписокЭтапов = ПолучитьЭтапыМаршрутовВКоторыхУчаствуетПользователь(ЭтапыСогласования);
	
	Список.Параметры.УстановитьЗначениеПараметра("ЭтапыСогласованияПользователя", ЭтапыСогласования);
	Список.Параметры.УстановитьЗначениеПараметра("ЭтапыМаршрутовВКоторыхУчаствуетПользователь", СписокЭтапов);
		
	МассивВидыОперацийРасчетыСКонтрагентами = Новый Массив;
	МассивВидыОперацийРасчетыСКонтрагентами.Добавить(Перечисления.ВидыОперацийЗаявкиНаРасходование.ВозвратДенежныхСредствПокупателю);
	МассивВидыОперацийРасчетыСКонтрагентами.Добавить(Перечисления.ВидыОперацийЗаявкиНаРасходование.ОплатаПоставщику);
	МассивВидыОперацийРасчетыСКонтрагентами.Добавить(Перечисления.ВидыОперацийЗаявкиНаРасходование.ПрочиеРасчетыСКонтрагентами);
	МассивВидыОперацийРасчетыСКонтрагентами.Добавить(Перечисления.ВидыОперацийЗаявкиНаРасходование.РасчетыПоКредитамИЗаймамСКонтрагентами);
	
	Список.Параметры.УстановитьЗначениеПараметра("ВидыОперацийРасчетыСКонтрагентами", МассивВидыОперацийРасчетыСКонтрагентами);
	
	Список.Параметры.УстановитьЗначениеПараметра("ТекПользователь", Объект.ТекущийПользователь);
		
	Список.Параметры.УстановитьЗначениеПараметра("СостояниеСогласован",  Перечисления.СостоянияОбъектов.Согласован);
	Список.Параметры.УстановитьЗначениеПараметра("СостояниеУтвержден",   Перечисления.СостоянияОбъектов.Утвержден);
	Список.Параметры.УстановитьЗначениеПараметра("СостояниеОтложен",     Перечисления.СостоянияОбъектов.Отложен);
	Список.Параметры.УстановитьЗначениеПараметра("СостояниеОтклонен",    Перечисления.СостоянияОбъектов.Отклонен);
	Список.Параметры.УстановитьЗначениеПараметра("СостояниеПодготовлен", Перечисления.СостоянияОбъектов.Подготовлен);
	
	ИзменитьКОплатеНаСегодня();
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "СтатусЗаявокБылИзменен" Тогда
		Элементы.Список.Обновить();
	КонецЕсли; 
	ИзменитьКОплатеНаСегодня();	
КонецПроцедуры

&НаСервере
Процедура ПриСохраненииДанныхВНастройкахНаСервере(Настройки)
	
	Настройки.Вставить("ОтборСписка", Список.Отбор);
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	ВосстановитьНастройкиОтборов(Настройки.Получить("ОтборСписка"));
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриИзменении(Элемент)
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
КонецПроцедуры

Процедура ИзменитьКОплатеНаСегодня()
	Если Не ЗначениеЗаполнено(Элементы.Список.Период.ДатаНачала) Тогда
		ДатаНач = НачалоДня(ТекущаяДата());
	Иначе
		ДатаНач = Элементы.Список.Период.ДатаНачала;	
	КонецЕсли; 			   
	Если Не ЗначениеЗаполнено(Элементы.Список.Период.ДатаОкончания) Тогда
		ДатаКон = КонецДня(ТекущаяДата());
	Иначе
		ДатаКон = Элементы.Список.Период.ДатаОкончания;	
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаявкаНаРасходованиеСредств.Ссылка,
	               |	СостоянияСогласованияЗаявокСрезПоследних.Состояние,
	               |	СостоянияСогласованияЗаявокСрезПоследних.Пользователь,
	               |	ВЫБОР
	               |		КОГДА ЗаявкаНаРасходованиеСредств.Проведен = ИСТИНА
	               |			ТОГДА ВЫБОР
	               |					КОГДА СостоянияСогласованияЗаявокСрезПоследних.Состояние <> ЗНАЧЕНИЕ(Перечисление.СостоянияОбъектов.Утвержден)
	               |						ТОГДА ""НЕОПЛАЧЕНО""
	               |					ИНАЧЕ ВЫБОР
	               |							КОГДА ВложенныйЗапрос.СуммаОстаток ЕСТЬ NULL
	               |								ТОГДА ""ОПЛАЧЕНО""
	               |							КОГДА НЕ ВложенныйЗапрос.СуммаОстаток ЕСТЬ NULL
	               |									И ВложенныйЗапрос.СуммаОстаток <> ЗаявкаНаРасходованиеСредств.СуммаДокумента
	               |								ТОГДА ""ОПЛАЧЕНО ЧАСТИЧНО""
	               |							ИНАЧЕ ""НЕОПЛАЧЕНО""
	               |						КОНЕЦ
	               |				КОНЕЦ
	               |	КОНЕЦ КАК ОПЛАТА,
	               |	ЗаявкаНаРасходованиеСредств.СуммаДокумента
	               |ПОМЕСТИТЬ ВсеЗаявки
	               |ИЗ
	               |	Документ.ЗаявкаНаРасходованиеСредств КАК ЗаявкаНаРасходованиеСредств
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СостоянияСогласованияЗаявок.СрезПоследних КАК СостоянияСогласованияЗаявокСрезПоследних
	               |		ПО ЗаявкаНаРасходованиеСредств.Ссылка = СостоянияСогласованияЗаявокСрезПоследних.Заявка
	               |		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	               |			ЗаявкиНаРасходованиеСредствОстатки.ЗаявкаНаРасходование КАК ЗаявкаНаРасходование,
	               |			ЗаявкиНаРасходованиеСредствОстатки.СуммаОстаток КАК СуммаОстаток
	               |		ИЗ
	               |			РегистрНакопления.ЗаявкиНаРасходованиеСредств.Остатки(&ДатаКон, ) КАК ЗаявкиНаРасходованиеСредствОстатки) КАК ВложенныйЗапрос
	               |		ПО ЗаявкаНаРасходованиеСредств.Ссылка = ВложенныйЗапрос.ЗаявкаНаРасходование
	               |ГДЕ
	               |	ЗаявкаНаРасходованиеСредств.ДатаРасхода = &ДатаНач
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВсеЗаявки.ОПЛАТА,
	               |	СУММА(ВсеЗаявки.СуммаДокумента) КАК СуммаДокумента
	               |ИЗ
	               |	ВсеЗаявки КАК ВсеЗаявки
	               |ГДЕ
	               |	ВсеЗаявки.ОПЛАТА = ""НЕОПЛАЧЕНО""
	               |	И ВсеЗаявки.Состояние = ЗНАЧЕНИЕ(Перечисление.СостоянияОбъектов.Утвержден)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВсеЗаявки.ОПЛАТА";
 			   
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	Запрос.УстановитьПараметр("ДатаКон", ДатаКон);
	ТЗ = Запрос.Выполнить().Выгрузить();
	Если ТЗ.Количество() <> 0 Тогда
		КОплатеНаСегодня = 	ТЗ.Итог("СуммаДокумента");
	Иначе
		КОплатеНаСегодня = 0;
	КонецЕсли; 
		Запрос.Текст = "ВЫБРАТЬ
		               |	ЗаявкаНаРасходованиеСредств.Ссылка,
		               |	СостоянияСогласованияЗаявокСрезПоследних.Состояние,
		               |	СостоянияСогласованияЗаявокСрезПоследних.Пользователь,
		               |	ВЫБОР
		               |		КОГДА ЗаявкаНаРасходованиеСредств.Проведен = ИСТИНА
		               |			ТОГДА ВЫБОР
		               |					КОГДА СостоянияСогласованияЗаявокСрезПоследних.Состояние <> ЗНАЧЕНИЕ(Перечисление.СостоянияОбъектов.Утвержден)
		               |						ТОГДА ""НЕОПЛАЧЕНО""
		               |					ИНАЧЕ ВЫБОР
		               |							КОГДА ВложенныйЗапрос.СуммаОстаток ЕСТЬ NULL
		               |								ТОГДА ""ОПЛАЧЕНО""
		               |							КОГДА НЕ ВложенныйЗапрос.СуммаОстаток ЕСТЬ NULL
		               |									И ВложенныйЗапрос.СуммаОстаток <> ЗаявкаНаРасходованиеСредств.СуммаДокумента
		               |								ТОГДА ""ОПЛАЧЕНО ЧАСТИЧНО""
		               |							ИНАЧЕ ""НЕОПЛАЧЕНО""
		               |						КОНЕЦ
		               |				КОНЕЦ
		               |	КОНЕЦ КАК ОПЛАТА,
		               |	ЗаявкаНаРасходованиеСредств.СуммаДокумента
		               |ПОМЕСТИТЬ ВсеЗаявки
		               |ИЗ
		               |	Документ.ЗаявкаНаРасходованиеСредств КАК ЗаявкаНаРасходованиеСредств
		               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СостоянияСогласованияЗаявок.СрезПоследних КАК СостоянияСогласованияЗаявокСрезПоследних
		               |		ПО ЗаявкаНаРасходованиеСредств.Ссылка = СостоянияСогласованияЗаявокСрезПоследних.Заявка
		               |		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		               |			ЗаявкиНаРасходованиеСредствОстатки.ЗаявкаНаРасходование КАК ЗаявкаНаРасходование,
		               |			ЗаявкиНаРасходованиеСредствОстатки.СуммаОстаток КАК СуммаОстаток
		               |		ИЗ
		               |			РегистрНакопления.ЗаявкиНаРасходованиеСредств.Остатки(, ) КАК ЗаявкиНаРасходованиеСредствОстатки) КАК ВложенныйЗапрос
		               |		ПО ЗаявкаНаРасходованиеСредств.Ссылка = ВложенныйЗапрос.ЗаявкаНаРасходование
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ВсеЗаявки.ОПЛАТА,
		               |	СУММА(ВсеЗаявки.СуммаДокумента) КАК СуммаДокумента
		               |ИЗ
		               |	ВсеЗаявки КАК ВсеЗаявки
		               |ГДЕ
		               |	ВсеЗаявки.ОПЛАТА = ""НЕОПЛАЧЕНО""
		               |	И ВсеЗаявки.Состояние = ЗНАЧЕНИЕ(Перечисление.СостоянияОбъектов.Утвержден)
		               |	И ВсеЗаявки.Ссылка.ДатаРасхода МЕЖДУ &ДатаНач И &ДатаКон
		               |
		               |СГРУППИРОВАТЬ ПО
		               |	ВсеЗаявки.ОПЛАТА";
	ДатаНач = Дата('00010101');
	ДатаКон = ДатаКон - 3600*24;
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	Запрос.УстановитьПараметр("ДатаКон", ДатаКон);
	ТЗ = Запрос.Выполнить().Выгрузить();
	Если ТЗ.Количество() <> 0 Тогда
		НеоплаченныеСуммыПрошлыхПериодов = 	ТЗ.Итог("СуммаДокумента");
	Иначе
		НеоплаченныеСуммыПрошлыхПериодов = 0;
	КонецЕсли;
КонецПроцедуры
 
