#Если Клиент Тогда
	
Перем ИмяРегистраБухгалтерии Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Формирует запрос по установленным условия, фильтрам и группировкам
//
Функция СформироватьЗапрос(СтруктураПараметров) Экспорт

	Запрос = Новый Запрос;

	Запрос.УстановитьПараметр("НачПериода",  НачалоДня(ДатаНач));
	Запрос.УстановитьПараметр("КонПериода",  КонецДня(ДатаКон));
	Запрос.УстановитьПараметр("Организация", Организация);

	ТекстЗапроса = "";
	ТекстИтогов  = "";
	ТекстЗапроса = ТекстЗапроса + 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Счет КАК Счет,
	|	Счет.Наименование КАК СчетНаименование,
	|	Счет.Представление КАК СчетПредставление,
	|	Счет.Код КАК СчетКод,
	|	Счет.Порядок КАК Порядок";
	
	Если ПоВалютам Тогда
		ТекстЗапроса = ТекстЗапроса + ",
		|	Валюта КАК Валюта,
		|	Валюта.Представление КАК ВалютаПредставление ";
	КонецЕсли;

	// Добавим в текст запроса все выбранные ресурсы 
	ТекстЗапроса = ТекстЗапроса + БухгалтерскиеОтчеты.ВернутьЧастьЗапросаПоВыборкеПолейОборотноСальдоваяВедомость(СтруктураПараметров.МассивПоказателей, Истина, 
			Истина, Истина);
			
	ТекстИтогов = ТекстИтогов + БухгалтерскиеОтчеты.ВернутьЧастьЗапросаПоВыборкеПолейОборотноСальдоваяВедомость(СтруктураПараметров.МассивПоказателей, Ложь);
	
	СтрокаТекстаВыборкиИзТаблицы = БухгалтерскиеОтчеты.СформироватьТекстВыборкиИзТаблицыОборотовИОстатковРегистраБухгалтерии(СтруктураПараметров, "БухРегОстаткиИОбороты");
	
	ТекстЗапроса = ТекстЗапроса + СтрокаТекстаВыборкиИзТаблицы;
		
	ТекстЗапроса = ТекстЗапроса + "
	|АВТОУПОРЯДОЧИВАНИЕ
	|ИТОГИ " + Сред(ТекстИтогов, 2) + "
	|ПО
	|	Счет ИЕРАРХИЯ";

	Если ПоВалютам Тогда
		ТекстЗапроса = ТекстЗапроса + ",
		|	Валюта КАК Валюта ";
	КонецЕсли;

	Запрос.Текст = ТекстЗапроса;

	Возврат Запрос;

КонецФункции // СформироватьЗапрос()

////////////////////////////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ПЕЧАТНОЙ ФОРМЫ ОТЧЕТА
//

// Формирует табличный документ с заголовком отчета
//
// Параметры:
//	Нет.
//
Функция СформироватьЗаголовок() Экспорт

	ОписаниеПериода = БухгалтерскиеОтчеты.СформироватьСтрокуВыводаПараметровПоДатам(ДатаНач, ДатаКон);
	
	
	Макет = ПолучитьОбщийМакет("ОборотноСальдоваяВедомость");
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");

	НазваниеОрганизации = Организация.НаименованиеПолное;
	Если ПустаяСтрока(НазваниеОрганизации) Тогда
		НазваниеОрганизации = Организация;
	КонецЕсли;
	
	ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	
	ЗаголовокОтчета.Параметры.Заголовок = ЗаголовокОтчета();

	ЗаголовокОтчета.Параметры.ОписаниеПериода = ОписаниеПериода;
	ТекстСписокПоказателей = НСтр("ru='Выводимые данные: сумма';uk='Виведені дані: сума'");
	Если ПоВалютам Тогда
		ТекстСписокПоказателей = ТекстСписокПоказателей + НСтр("ru=', валютная сумма';uk=', валютна сума'");
	КонецЕсли;

    ЗаголовокОтчета.Параметры.СписокПоказателей = ТекстСписокПоказателей;

	Возврат ЗаголовокОтчета;
	
КонецФункции // СформироватьЗаголовок()

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Истина, ВысотаЗаголовка = 0) Экспорт

	БухгалтерскиеОтчеты.СформироватьОтчетОборотноСальдовойВедомости(ЭтотОбъект, ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, 
	ПоВалютам,	Ложь, Ложь,); 
			
КонецПроцедуры // СформироватьОтчет()

//Функция возвращает общую структуру для расшифровки
Функция СформироватьОбщуюСтруктуруДляРасшифровки() Экспорт
	
	СтруктураНастроекОтчета = Новый Структура;
	
	СтруктураНастроекОтчета.Вставить("ДатаНач", ДатаНач);
	СтруктураНастроекОтчета.Вставить("ДатаКон", ДатаКон);
	СтруктураНастроекОтчета.Вставить("Организация", Организация);
			
	Возврат СтруктураНастроекОтчета;
	
КонецФункции

//Функция возвращает массив показателей для отчета
Функция СформироватьМассивПоказателей() Экспорт
	
	МассивПоказателей = Новый Массив;
	МассивПоказателей.Добавить("Сумма");
	
	Если ПоВалютам Тогда
		МассивПоказателей.Добавить("ВалютнаяСумма");
	КонецЕсли;
	
	Возврат МассивПоказателей;
		
КонецФункции

Функция ЗаголовокОтчета() Экспорт
	Возврат "Оборотно-сальдовая ведомость (налоговый учет)";
КонецФункции // ЗаголовокОтчета()

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

ИмяРегистраБухгалтерии = "Налоговый";

БухгалтерскиеОтчеты.СоздатьКолонкиУПравилВыводаИтоговИПравилаРазвернутогоСальдо(ПравилаВыводаИтогов, ПравилаРазвернутогоСальдо, ИмяРегистраБухгалтерии);

#КонецЕсли