#Если Клиент Тогда

////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

// Хранит таблицу значений - состав показателей отчета
Перем мТаблицаСоставПоказателей Экспорт;

// Хранит структуру - состав показателей отчета,
// значение которых автоматически заполняется по учетным данным.
Перем мСтруктураВариантыЗаполнения Экспорт;

// Хранит структуру многостраничных разделов
Перем мСтруктураМногостраничныхРазделов Экспорт;

// Хранит дерево значений - структуру листов отчета.
Перем мДеревоСтраницОтчета Экспорт;

// Хранит признак выбора печатных листов
Перем мЕстьВыбранные Экспорт;

// Хранит имя выбранной формы отчета
Перем мВыбраннаяФорма Экспорт;

// Хранит признак скопированной формы.
Перем мСкопированаФорма Экспорт;

// Хранит ссылку на документ РегламентированныйОтчет,
// хранящий данные отчета
Перем мСохраненныйДок Экспорт;

// Следующие переменные хранят границы
// периода построения отчета
Перем мДатаНачалаПериодаОтчета Экспорт;
Перем мДатаКонцаПериодаОтчета  Экспорт;

Перем мТаблицаФормОтчета Экспорт;
Перем мПолноеИмяФайлаВнешнейОбработки Экспорт;
Перем мЗаписьЗапрещена                Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Формирует дерево значений - структуру страниц отчета,
// содержащей настройки показа страниц, вывода на печать и выгрузки в ИМНС.
//  требуется редакция по наименованиям ПолейТабличныхДокументов
////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ 

МассивТипов = Новый Массив; 
МассивТипов.Добавить(Тип("Строка"));
ОписаниеТиповСтрока15  = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыСтроки(15, ДопустимаяДлина.Переменная));

МассивТипов = Новый Массив; 
МассивТипов.Добавить(Тип("Строка"));
ОписаниеТиповСтрока254 = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыСтроки(254, ДопустимаяДлина.Переменная));

МассивБулево = Новый Массив;
МассивБулево.Добавить(Тип("Булево"));
ОписаниеТиповБулево    = Новый ОписаниеТипов(МассивБулево);

// Таблица значений хранит состав показателей отчета.
// В колонках таблицы хранятся следующие данные:
//    - имя поля табличного документа;
//    - код показатели по составу показателей;
//    - код показателя по форме (имя области табличного документа);
//    - признак многострочности;
//    - тип данных показателя.
//
мТаблицаСоставПоказателей         = Новый ТаблицаЗначений;
мТаблицаСоставПоказателей.Колонки.Добавить("ИмяПоляТаблДокумента",    ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоСоставу",  ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоФорме",    ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("ПризнМногострочности",    ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("ТипДанныхПоказателя",     ОписаниеТиповСтрока15);


мСтруктураВариантыЗаполнения      = Новый Структура;

МассивТипов = Новый Массив; 
МассивТипов.Добавить(Тип("Строка"));
ОписаниеТиповСтрока = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыСтроки(254, ДопустимаяДлина.Переменная));

МассивТипов = Новый Массив;
МассивТипов.Добавить(Тип("Дата"));
ОписаниеТиповДата = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыДаты(ЧастиДаты.Дата));

мТаблицаФормОтчета = Новый ТаблицаЗначений;
мТаблицаФормОтчета.Колонки.Добавить("ФормаОтчета",        ОписаниеТиповСтрока);
мТаблицаФормОтчета.Колонки.Добавить("ОписаниеОтчета",     ОписаниеТиповСтрока, НСтр("ru='Утверждена';uk='Затверджена'"),  20);
мТаблицаФормОтчета.Колонки.Добавить("ДатаНачалоДействия", ОписаниеТиповДата,   НСтр("ru='Действует с';uk='Діє з'"), 5);
мТаблицаФормОтчета.Колонки.Добавить("ДатаКонецДействия",  ОписаниеТиповДата,   НСтр("ru='         по';uk='         по'"), 5);


НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2008";
НоваяФорма.ОписаниеОтчета     = НСтр("ru='Утверждена приказом ГНАУ  23.10.98  N 499 (в редакции приказа ГНА от 17.03.2008 № 159)';uk='Затверджена наказом ДПАУ  23.10.98  N 499 ((у редакції наказу ДПА України от 17.03.2008 № 159))'");
НоваяФорма.ДатаНачалоДействия = '20080101';
НоваяФорма.ДатаКонецДействия  = ОбщегоНазначения.ПустоеЗначениеТипа(Тип("Дата"));;



#КонецЕсли
