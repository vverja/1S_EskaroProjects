#Если Клиент Тогда

Перем НП Экспорт;

Перем ИмяРегистраБухгалтерии Экспорт;

Перем МаксКоличествоСубконто Экспорт; // Количество субконто у регистра бухгалтерии

Перем ЕстьВалюта Экспорт;
Перем ЕстьКоличество Экспорт;

Перем МассивШиринКолонок;
Перем ШиринаТаблицы;
Перем ЗаголовокОтчета Экспорт;

Перем кэшВидовСубконто;

//////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ЗАГОЛОВКА ОТЧЕТА
//

// Выводит заголовок отчета
//
// Параметры:
//	Нет.
//
Функция СформироватьЗаголовок() Экспорт

	// Вывод заголовка, описателя периода и фильтров и заголовка
	Если ДатаНач = '00010101000000' И ДатаКон = '00010101000000' Тогда

		ОписаниеПериода     = "Период: без ограничения.";

	Иначе

		Если ДатаНач = '00010101000000' ИЛИ ДатаКон = '00010101000000' Тогда
			ОписаниеПериода = "Период: " + Формат(ДатаНач, "ДФ = ""дд.ММ.гггг""; ДП = ""без ограничения""") 
							+ " - "      + Формат(ДатаКон, "ДФ = ""дд.ММ.гггг""; ДП = ""без ограничения""");
		Иначе
			ОписаниеПериода = "Период: " + ПредставлениеПериода(НачалоДня(ДатаНач), КонецДня(ДатаКон), "ФП = Истина");
		КонецЕсли;

	КонецЕсли;
	
	Макет = ПолучитьМакет("Макет");
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");

	НазваниеОрганизации = Организация.НаименованиеПолное;
	Если ПустаяСтрока(НазваниеОрганизации) Тогда
		НазваниеОрганизации = Организация;
	КонецЕсли;
	
	ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	
	ЗаголовокОтчета.Параметры.ОписаниеПериода = ОписаниеПериода;

	ТекстПроСписокРесурсов = "Выводимые данные: сумма";
	
	Если ПоВалютам Тогда
	
		ТекстПроСписокРесурсов = ТекстПроСписокРесурсов + ", валютная сумма";
	
	КонецЕсли; 

	Если ПоКоличеству Тогда
	
		ТекстПроСписокРесурсов = ТекстПроСписокРесурсов + ", количество";
	
	КонецЕсли; 
	
	ТекстПроИтоги = "";
	Для каждого Строка Из Субконто Цикл
		
		ТекстПроИтоги = ТекстПроИтоги + ", " + Строка(Строка.ВидСубконто);
		
	КонецЦикла;
	
	ТекстПроИтоги = "Виды субконто: " + Сред(ТекстПроИтоги, 3);
	
	// Вывод списка фильтров:
	СтрОтбор = "";

	СтрОтбор = Сред(СтрОтбор + ", " + УправлениеОтчетами.СформироватьСтрокуОтборов(ПостроительОтчета.Отбор), 3);

	Заголовок = ЗаголовокОтчета();

	ЗаголовокОтчета.Параметры.ТекстПроСписокРесурсов = ТекстПроСписокРесурсов;
	ЗаголовокОтчета.Параметры.ТекстПроИтоги = ТекстПроИтоги;

	ЗаголовокОтчета.Параметры.Заголовок              = Заголовок;

	Если Не ПустаяСтрока(СтрОтбор) Тогда
		ОбластьОтбор = Макет.ПолучитьОбласть("СтрокаОтбор");
		ОбластьОтбор.Параметры.ТекстПроОтбор = "Отбор: " + СтрОтбор;
		ЗаголовокОтчета.Вывести(ОбластьОтбор);
	КонецЕсли;

	Возврат(ЗаголовокОтчета);

	Возврат Новый ТабличныйДокумент;

КонецФункции // СформироватьЗаголовок()

Функция ЗаголовокОтчета() Экспорт
	Возврат "Анализ субконто";
КонецФункции // ЗаголовокОтчета()

//////////////////////////////////////////////////////////
// СОХРАНЕНИЕ И ВОССТАНОВЛЕНИЕ ПАРАМЕТРОВ ОТЧЕТА
//

// Формирование структуры для сохранения настроек отчета.
// В структуру заносятся значимые реквизиты отчета
//
// Возвращаемое значение:
//    Структура
Функция СформироватьСтруктуруДляСохраненияНастроек() Экспорт

	СтруктураНастроек = Новый Структура;
	
	СтруктураНастроек.Вставить("Организация", Организация);
	
	СтруктураНастроек.Вставить("ДатаНач", ДатаНач);
	СтруктураНастроек.Вставить("ДатаКон", Макс(ДатаНач, ДатаКон));
	
	СтруктураНастроек.Вставить("ПоВалютам",    ПоВалютам);
	СтруктураНастроек.Вставить("ПоКоличеству", ПоКоличеству);
	СтруктураНастроек.Вставить("ПоСубсчетам",  ПоСубсчетам);
	
	СтруктураНастроек.Вставить("ВидыСубконто",  Субконто.Выгрузить());
	
	СтруктураНастроек.Вставить("НастройкиПостроителя", ПостроительОтчета.ПолучитьНастройки());
	
	Возврат СтруктураНастроек;

КонецФункции // СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок)

// Восстановление значимых реквизитов отчета из структуры
//
// Параметры:
//    Структура   - структура, которая содержит значения реквизитов отчета
Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт

	Перем НастройкиПостроителя;
	Перем ВидыСубконто;
	
	Если ТипЗнч(СтруктураСНастройками) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("Организация", Организация);
	
	СтруктураСНастройками.Свойство("ДатаНач", ДатаНач);
	СтруктураСНастройками.Свойство("ДатаКон", ДатаКон);
	
	СтруктураСНастройками.Свойство("ПоВалютам",    ПоВалютам);
	СтруктураСНастройками.Свойство("ПоКоличеству", ПоКоличеству);
	СтруктураСНастройками.Свойство("ПоСубсчетам",  ПоСубсчетам);
	
	СтруктураСНастройками.Свойство("ВидыСубконто",  ВидыСубконто);
	Если ТипЗнч(ВидыСубконто) = Тип("ТаблицаЗначений") Тогда
		Субконто.Загрузить(ВидыСубконто);
	КонецЕсли;
	
	// После установки счета и флагов можно заполнять текст построителя
	ЗаполнитьНачальныеНастройки();
	
	СтруктураСНастройками.Свойство("НастройкиПостроителя", НастройкиПостроителя);
	Если ТипЗнч(НастройкиПостроителя) = Тип("НастройкиПостроителяОтчета") Тогда
		ПостроительОтчета.УстановитьНастройки(НастройкиПостроителя, Истина, Истина, Истина, Истина);
	КонецЕсли;
	
	Для каждого СтрокаСубконто Из Субконто Цикл
		НомерСубконто = СтрокаСубконто.НомерСтроки;
		Если ПостроительОтчета.Отбор.Найти("Субконто"+НомерСубконто) = Неопределено Тогда
			ПостроительОтчета.Отбор.Добавить("Субконто"+НомерСубконто);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры


//////////////////////////////////////////////////////////
// ПОСТРОЕНИЕ ОТЧЕТА
//

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//  ДокументРезультат - табличный документ, формируемый отчетом
//
Процедура СформироватьОтчет(ДокументРезультат,  ПоказыватьЗаголовок = Истина, ВысотаЗаголовка = 0) Экспорт

	Если ДатаНач > ДатаКон И ДатаКон <> '00010101000000' Тогда
		Предупреждение("Дата начала периода не может быть больше даты конца периода", 60);
		Возврат;
	КонецЕсли;
	
	Если Субконто.Количество() = 0 Тогда
		Предупреждение("Не указан ни один вид субконто", 60);
		Возврат;
	КонецЕсли;
	
	кэшВидовСубконто.Очистить();

	// Запоминание ширины колонки
	Если НЕ ДокументРезультат.ВысотаТаблицы = ВысотаЗаголовка Тогда

		МассивШиринКолонок.Очистить();

		// Запоминать следует, если документ не пустой
		Если ДокументРезультат.ВысотаТаблицы > 0 Тогда
			
			Для Сч=1 По ШиринаТаблицы Цикл
				МассивШиринКолонок.Добавить(ДокументРезультат.Область(1,Сч).ШиринаКолонки);
			КонецЦикла;
			
		КонецЕсли;

	КонецЕсли;
	
	ДокументРезультат.Очистить();
	
	ТекстОтбор = "";
	ТекстСубконто = "";
	ТекстСубконтоИтоги = "";
	
	Запрос = Новый Запрос;
	
	ВидыСубконто =Новый Массив;
	
	// Добавим измерения
	МассивСубконто = Новый Массив;
	
	Для каждого стр Из Субконто Цикл
		
		ВидыСубконто.Добавить(стр.ВидСубконто);
		МассивСубконто.Добавить("Субконто"+стр.НомерСтроки);
		
		ТекстСубконто = ТекстСубконто + СтрЗаменить(",
		|	Субконто{н} КАК Субконто{н},
		|	ПРЕДСТАВЛЕНИЕ(Субконто{н}) КАК Субконто{н}Представление", "{н}", стр.НомерСтроки);
		
		ТекстСубконтоИтоги = ТекстСубконтоИтоги + СтрЗаменить(",
		|	Субконто{н} КАК Субконто{н}", "{н}", стр.НомерСтроки);
		
	КонецЦикла;
	
	Если ЗначениеЗаполнено(Организация) Тогда
		ТекстОтбор = ТекстОтбор + " И Организация = &Организация";
	КонецЕсли;

	МассивРесурсов = Новый Массив;
	МассивРесурсов.Добавить("Сумма");
	
	Если ПоВалютам Тогда
		МассивРесурсов.Добавить("ВалютнаяСумма");
	КонецЕсли; 
	
	Если ПоКоличеству Тогда
		МассивРесурсов.Добавить("Количество");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Видысубконто", ВидыСубконто);
	
	Запрос.УстановитьПараметр("Организация", Организация);
	
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	
	Если ДатаНач='00010101000000' Тогда
		Запрос.УстановитьПараметр("ДатаНач", ДатаНач+1);
	КонецЕсли;
	
	Если ДатаКон <> '00010101000000' Тогда
		Запрос.УстановитьПараметр("ДатаКон", КонецДня(ДатаКон));
	Иначе
		Запрос.УстановитьПараметр("ДатаКон", ДатаКон);
	КонецЕсли;
	
	Сч = 0;
	ТекстОтборСчетов = "";
	Для каждого Элемент Из ПостроительОтчета.Отбор Цикл
		
		Если НЕ Элемент.Использование ИЛИ ПустаяСтрока(Элемент.ПутьКДанным) Тогда
			Продолжить;
		КонецЕсли;
		
		Если Врег(Лев(Элемент.ПутьКДанным, 4))="СЧЕТ" Тогда
			ТекстОтборСчетов = ТекстОтборСчетов + " И " + УправлениеОтчетами.ПолучитьСтрокуОтбора(Элемент.ВидСравнения, "&Значение"+Сч, Элемент.ПутьКДанным, "&ЗначениеС"+Сч, "&ЗначениеПо"+Сч, Элемент.Значение, Элемент.ЗначениеС, Элемент.ЗначениеПо);
			
		Иначе
			ТекстОтбор = ТекстОтбор + " И " + УправлениеОтчетами.ПолучитьСтрокуОтбора(Элемент.ВидСравнения, "&Значение"+Сч, Элемент.ПутьКДанным, "&ЗначениеС"+Сч, "&ЗначениеПо"+Сч, Элемент.Значение, Элемент.ЗначениеС, Элемент.ЗначениеПо);
		КонецЕсли;
		
		БухгалтерскиеОтчеты.УстановитьПараметрыЗапросаПоСтрокеПостроителяОтчета(Запрос, Элемент, Строка(Сч));
		
		Сч=Сч+1;
	
	КонецЦикла;
	
	СоответствиеКорСубконто = Новый Соответствие;
	
	Текст = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	БухОбороты.Счет КАК Счет, 
	|	БухОбороты.Счет.Количественный КАК СчетКоличественный, 
	|	БухОбороты.Счет.Вид КАК ВидСчета, 
	|	БухОбороты.Счет.Валютный КАК СчетВалютный, 
	|	БухОбороты.Счет.Порядок КАК СчетПорядок, 
	|	БухОбороты.Счет.Представление КАК СчетПредставление"+ТекстСубконто;
	
	Если ПоКоличеству Тогда
		Текст = Текст + ",
		|	ВЫБОР КОГДА БухОбороты.Счет.Количественный ТОГДА Истина ИНАЧЕ Ложь КОНЕЦ КАК ЕстьКоличественныеСчета ";
	Иначе
		Текст = Текст + ",
		|	Ложь КАК ЕстьКоличественныеСчета ";
	КонецЕсли;
	
	Если ПоВалютам Тогда
		Текст = Текст + ",
		|	БухОбороты.Валюта КАК Валюта, БухОбороты.Валюта.Представление КАК ВалютаПредставление  ";
	КонецЕсли;
	
	Для каждого ИмяРесурса Из МассивРесурсов Цикл
		
		Текст = Текст + ",
		|	" +ИмяРесурса+ "ОборотДт КАК " +ИмяРесурса+ "ОборотДт,
		|	" +ИмяРесурса+ "ОборотКт КАК " +ИмяРесурса+ "ОборотКт,
		|	" +ИмяРесурса+ "НачальныйОстатокДт КАК " +ИмяРесурса+ "НачДт,
		|	" +ИмяРесурса+ "НачальныйОстатокКт КАК " +ИмяРесурса+ "НачКт,
		|	" +ИмяРесурса+ "КонечныйОстатокДт КАК " +ИмяРесурса+ "КонДт,
		|	" +ИмяРесурса+ "КонечныйОстатокКт КАК " +ИмяРесурса+ "КонКт";
		
	КонецЦикла;
	
	Текст = Текст + "
	|ИЗ
	|	РегистрБухгалтерии."+ИмяРегистраБухгалтерии+".ОстаткиИОбороты(&ДатаНач, &ДатаКон, , , " + Сред(ТекстОтборСчетов, 3)+ ", &ВидыСубконто, " + Сред(ТекстОтбор, 3) + ") КАК БухОбороты
	| ";
	
	ТекстИтоги = "";
	
	ТекстПорядок = "";
	
	Для каждого Элемент Из ПостроительОтчета.Порядок Цикл
	
		Если ПустаяСтрока(Элемент.ПутьКДанным) Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстПорядок = ТекстПорядок + ", " + Элемент.ПутьКДанным + " "+ ?(Элемент.Направление = НаправлениеСортировки.Возр, "Возр", "Убыв");
		
	КонецЦикла;

	Если Не ПустаяСтрока(ТекстПорядок) Тогда
		
		Текст = Текст + "
		|УПОРЯДОЧИТЬ ПО
		|	" + Сред(ТекстПорядок, 2);
		
	Иначе
		
		Текст = Текст + "
		|АВТОУПОРЯДОЧИВАНИЕ";
		
	КонецЕсли;
	
	Для каждого ИмяРесурса Из МассивРесурсов Цикл
	
		ТекстИтоги = ТекстИтоги + ",
		|	СУММА(" +ИмяРесурса+ "ОборотДт),
		|	СУММА(" +ИмяРесурса+ "ОборотКт),
		|	СУММА(" +ИмяРесурса+ "НачДт),
		|	СУММА(" +ИмяРесурса+ "НачКт)";
	
	КонецЦикла; 
	
	
	Текст = Текст + "
	|ИТОГИ " + Сред(ТекстИтоги, 2)+ ", МАКСИМУМ(ЕстьКоличественныеСчета)
	|	ПО ОБЩИЕ";
	
	Текст = Текст + ",
	|	Счет ИЕРАРХИЯ КАК Счет";
	
	// добавим итоги по субконто
	Текст = Текст + ТекстСубконтоИтоги;
	
	Если ПоВалютам Тогда
		Текст = Текст + ", Валюта КАК Валюта";
	КонецЕсли;
	
	Запрос.Текст = Текст;
	
	Состояние("Выполнение запроса");
	Результат = Запрос.Выполнить();
	
	Макет       = ПолучитьМакет("Макет");
	

	// Вывод заголовка отчета
	ОбластьЗаголовка = СформироватьЗаголовок();
	ВысотаЗаголовка  = ОбластьЗаголовка.ВысотаТаблицы;
	
	ДокументРезультат.Вывести(ОбластьЗаголовка, 1);

	Если ЗначениеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;
	
	ОбластьЗаголовкаТаблицы = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
	ДокументРезультат.Вывести(ОбластьЗаголовкаТаблицы, 1);
	
	ОбщийИтог = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Общие");
	ЕстьИтог = ОбщийИтог.Следующий();
	
	// Валюта
	ОбластьСтрокаВалюта       = Макет.ПолучитьОбласть("СтрокаВалюта");
	
	// Субконто
	
	ВыводКоличества = ПоКоличеству;
	Если ЕстьИтог Тогда
		ВыводКоличества = ПоКоличеству И ОбщийИтог.ЕстьКоличественныеСчета;
	КонецЕсли;
	
	ОбластьСтрокаСубконто  = Макет.ПолучитьОбласть("СтрокаСубконто");
	ОбластьИтогСубконто    = Макет.ПолучитьОбласть("ИтогСубконто");
	ОбластьИтогСубконтоКоличество    = Макет.ПолучитьОбласть("ИтогСубконтоКоличество");
	
	// Счет
	ОбластьСтрокаСчет      = Макет.ПолучитьОбласть("СтрокаСчет");
	ОбластьСтрокаСчетКоличество   = Макет.ПолучитьОбласть("СтрокаСчетКоличество");

	// Сдвиг уровня выводимой группировки отчета относительно группировки запроса
	СдвигУровня = 0;
	
	// Флаг сброса сдвига уровня при выводе группировки по счету
	СброситьСдвигУровня = Истина;

	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("ОбластьСтрокаСчет", ОбластьСтрокаСчет);
	СтруктураПараметров.Вставить("ОбластьСтрокаСчетКоличество", ОбластьСтрокаСчетКоличество);
	СтруктураПараметров.Вставить("ОбластьСтрокаВалюта", ОбластьСтрокаВалюта);
	
	СтруктураПараметров.Вставить("ОбластьСтрокаСубконто", ОбластьСтрокаСубконто);
	СтруктураПараметров.Вставить("ОбластьИтогСубконто", ОбластьИтогСубконто);
	СтруктураПараметров.Вставить("ОбластьИтогСубконтоКоличество", ОбластьИтогСубконтоКоличество);
	
	СтруктураПараметров.Вставить("ДокументРезультат", ДокументРезультат);
	
	СтруктураПараметров.Вставить("МассивСубконто", МассивСубконто);
	
	СтруктураПараметров.Вставить("ДокументРезультат", ДокументРезультат);
	
	// Вывод отчета

	ДокументРезультат.НачатьАвтогруппировкуСтрок();

	ВывестиСубконто(Результат, СтруктураПараметров);
	
	ДокументРезультат.ЗакончитьАвтогруппировкуСтрок();
	
	// Итого по отчету
	
	ОбластьИтог = Макет.ПолучитьОбласть("ИтогОтчет");
	ОбластьИтог.Параметры.Заполнить(ОбщийИтог);
	
	Если ЕстьИтог Тогда
		СуммаКонДт = ОбщийИтог.СуммаНачДт + ОбщийИтог.СуммаОборотДт;
		СуммаКонКт = ОбщийИтог.СуммаНачКт + ОбщийИтог.СуммаОборотКт;
		
		Если СуммаКонДт>СуммаКонКт Тогда
			СуммаКонДт=СуммаКонДт-СуммаКонКт;
			СуммаКонКт=0;
		Иначе
			СуммаКонКт=СуммаКонКт-СуммаКонДт;
			СуммаКонДт=0;
		КонецЕсли;
		
		ОбластьИтог.Параметры.СуммаКонДт =СуммаКонДт;
		ОбластьИтог.Параметры.СуммаКонКт =СуммаКонКт;
	КонецЕсли;
	
	
	ДокументРезультат.Вывести(ОбластьИтог);
	
	// Заполним общую расшифровку:
	СтруктураНастроекОтчета = Новый Структура;

	СтруктураНастроекОтчета.Вставить("ДатаНач", ДатаНач);
	СтруктураНастроекОтчета.Вставить("ДатаКон", ДатаКон);
	СтруктураНастроекОтчета.Вставить("Организация", Организация);
	СтруктураНастроекОтчета.Вставить("ПоказыватьЗаголовок", ПоказыватьЗаголовок);

	ДокументРезультат.Область(1,1).Расшифровка = СтруктураНастроекОтчета;
	
	// Обведение таблицы отчета линией, как в области границы
	ТолстаяЛиния = ОбластьИтог.Область(ОбластьИтог.ВысотаТаблицы, 2).ГраницаСнизу;
	
	ДокументРезультат.Область(ВысотаЗаголовка+2, 2, ДокументРезультат.ВысотаТаблицы, ДокументРезультат.ШиринаТаблицы).Обвести(ТолстаяЛиния, ТолстаяЛиния, ТолстаяЛиния, ТолстаяЛиния);
	
	ШиринаТаблицы = ДокументРезультат.ШиринаТаблицы;
	
	// Восстановление ширин колонок
	Если ТипЗнч(МассивШиринКолонок) = Тип("Массив") Тогда
		Если МассивШиринКолонок.Количество() = ШиринаТаблицы Тогда
			Инд = 0;
			Для Каждого Элемент Из МассивШиринКолонок Цикл
				ДокументРезультат.Область(,1+Инд, , 1+Инд).ШиринаКолонки = Элемент;
				Инд = Инд+1;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;

	// Зафиксируем заголовок отчета
	ДокументРезультат.ФиксацияСверху = ВысотаЗаголовка + 3;
	
	// Шапка отчета должна быть на каждом листе
	ДокументРезультат.ПовторятьПриПечатиСтроки = ДокументРезультат.Область(ВысотаЗаголовка+1,,ВысотаЗаголовка + 3);
	
	// Первую колонку не печатаем
	ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
	
	// Присвоим имя для сохранения параметров печати табличного документа
	ДокументРезультат.ИмяПараметровПечати = "АнализСубконто"+ИмяРегистраБухгалтерии;
	
	УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(ДокументРезультат, ЗаголовокОтчета(), Строка(глЗначениеПеременной("глТекущийПользователь")));
	
КонецПроцедуры

// Заполняет параметры расшифровки
//
// Параметры:
//	Нет.
//
Процедура ЗаполнитьПараметрыРасшифровки(Область, Выборка, ОтборСубконто = Неопределено)

	ПараметрыКарточкиСчета = Новый Структура;
	
	ПараметрыКарточкиСчета.Вставить("ИмяОбъекта", "КарточкаСчета"+ИмяРегистраБухгалтерии);
	ПараметрыКарточкиСчета.Вставить("Счет", Выборка.Счет);
	ПараметрыКарточкиСчета.Вставить("СпособРасшифровки", "Отчет");

	ПараметрыКарточкиСубконто = Новый Структура;
	
	ПараметрыКарточкиСубконто.Вставить("ИмяОбъекта", "КарточкаСубконто"+ИмяРегистраБухгалтерии);
	ПараметрыКарточкиСубконто.Вставить("СпособРасшифровки", "Отчет");
	
	Если Лев(Выборка.Группировка(), СтрДлина(Выборка.Группировка()) - 1) = "Субконто" Тогда

		Если ОтборСубконто <> Неопределено Тогда
			
			ОтборСубконто.Вставить(Выборка.Группировка(), Выборка[Выборка.Группировка()]);
			
			// Область должна содержать свою копию отбора по субконто
			ОтборРасшифровка = БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборСубконто);
			
			ПараметрыКарточкиСубконто.Вставить("Отбор", ОтборРасшифровка);
			ПараметрыКарточкиСубконто.Вставить("ВидыСубконто", Субконто.ВыгрузитьКолонку("ВидСубконто"));
			
		КонецЕсли;

		СписокРасшифровки = Новый СписокЗначений;

		СписокРасшифровки.Добавить(ПараметрыКарточкиСубконто, "Карточка субконто " + Выборка.Группировка());
		
	ИначеЕсли Выборка.Группировка() = "Счет" Тогда

		СписокРасшифровки = Новый СписокЗначений;
		
		Если ОтборСубконто <> Неопределено Тогда
			
			// Область должна содержать свою копию отбора по субконто
			
			тзВидыСубконто = кэшВидовСубконто[Выборка.Счет];
			Если тзВидыСубконто = Неопределено Тогда
				
				тзВидыСубконто = Выборка.Счет.ВидыСубконто;
				кэшВидовСубконто.Вставить(Выборка.Счет, тзВидыСубконто);
				
			КонецЕсли;
			
			ОтборРасшифровка = Новый Соответствие;
			
			Для каждого Элемент Из ОтборСубконто Цикл
			
				НомерСубконто = Число(Прав(Элемент.Ключ, СтрДлина(Элемент.Ключ)-8));
				
				НовыйНомерСубконто = ПолучитьНомерСубконтоСчета(Субконто[НомерСубконто-1].ВидСубконто, Выборка.Счет, тзВидыСубконто);
				
				Если НовыйНомерСубконто <> 0 Тогда
				
					ОтборРасшифровка.Вставить("Субконто"+НовыйНомерСубконто, Элемент.Значение);
				
				КонецЕсли;
				
			КонецЦикла;
			
			ПараметрыКарточкиСчета.Вставить("Отбор", ОтборРасшифровка);
			
		КонецЕсли;
		
		СписокРасшифровки.Добавить(ПараметрыКарточкиСчета, "Карточка счета " + Выборка.Счет);
		
	Иначе
		СписокРасшифровки = Неопределено;
	КонецЕсли;

	Область.Параметры.Расшифровка = СписокРасшифровки;

КонецПроцедуры // ЗаполнитьПараметрыРасшифровки()

// Вывод в отчет строки счетов
Процедура ВывестиСчета(Выборка, СтруктураПараметров, ОтборДляРасшифровки = Неопределено)
	
	ВыборкаПоСчетам = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией, "Счет");
	
	Пока ВыборкаПоСчетам.Следующий() Цикл
		
		// Вывод нач сальдо
		Если ВыборкаПоСчетам.ЕстьКоличественныеСчета Тогда
			ВыводимаяОбласть = СтруктураПараметров.ОбластьСтрокаСчетКоличество;
		Иначе
			ВыводимаяОбласть = СтруктураПараметров.ОбластьСтрокаСчет;
		КонецЕсли;
		
		ВыводимаяОбласть.Параметры.Заполнить(ВыборкаПоСчетам);
		
		Уровень = ВыборкаПоСчетам.Уровень();
		
		// Расшифровка
		ЗаполнитьПараметрыРасшифровки(ВыводимаяОбласть, ВыборкаПоСчетам, ОтборДляРасшифровки);
		
		СтруктураПараметров.ДокументРезультат.Вывести(ВыводимаяОбласть, Уровень);
		// Вывод начального сальдо: конец
		
		// Вывод вложенных итогов
		
		// Вывод валют
		Если ПоВалютам И ВыборкаПоСчетам.СчетВалютный=Истина Тогда
			
			ВывестиВалюты(ВыборкаПоСчетам, СтруктураПараметров, БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки));
		КонецЕсли;
		
		Если Уровень = 0 Тогда
			// Выводим 2 верхних уровня - классы счетов и счета
			ВывестиСчета(ВыборкаПоСчетам, СтруктураПараметров, БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки));
		ИначеЕсли ПоСубсчетам Тогда
			// Если нужно выводить субсчета, выберем следующий уровень счетов
			ВывестиСчета(ВыборкаПоСчетам, СтруктураПараметров, БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки));
		КонецЕсли;
		// Вывод вложенных итогов: конец

		
	КонецЦикла;
	
КонецПроцедуры

// Вывод в отчет строки валют
Процедура ВывестиВалюты(Выборка, СтруктураПараметров, ОтборДляРасшифровки)
	
	ВыборкаВалют = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Валюта");

	Пока ВыборкаВалют.Следующий() Цикл
		
		// Вывод нач сальдо
		ВыводимаяОбласть = СтруктураПараметров.ОбластьСтрокаВалюта;
		
		ВыводимаяОбласть.Параметры.Заполнить(ВыборкаВалют);
		
		Уровень = ВыборкаВалют.Уровень();
		
		// Расшифровка
		ЗаполнитьПараметрыРасшифровки(ВыводимаяОбласть, ВыборкаВалют);
		
		СтруктураПараметров.ДокументРезультат.Вывести(ВыводимаяОбласть, Уровень);
		// Вывод начального сальдо: конец
				
	КонецЦикла;

КонецПроцедуры

// Вывод субконто: общая процедура
Процедура ВывестиСубконто(Выборка, СтруктураПараметров)
	
	ВыводСубконто(Выборка, 0, СтруктураПараметров, Новый Соответствие);
	
КонецПроцедуры

// Вывод субконто определенного номера
Процедура ВыводСубконто(Выборка, Знач Инд, СтруктураПараметров, ОтборДляРасшифровки)
	
	Если Инд<= СтруктураПараметров.МассивСубконто.Количество()-1 Тогда
		
		Измерение = СтруктураПараметров.МассивСубконто[Инд];
		
		Если Инд=0 Тогда
			ОтборДляРасшифровки = Новый Соответствие;
		КонецЕсли;
		
		ВыборкаПоСубконто = Выборка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, Измерение);
		
		Пока ВыборкаПоСубконто.Следующий() Цикл
			
			// Вывод нач сальдо
			ВыводимаяОбласть = СтруктураПараметров.ОбластьСтрокаСубконто;
			
			ВыводимаяОбласть.Параметры.СубконтоПредставление = ВыборкаПоСубконто[Измерение+"Представление"];
			ВыводимаяОбласть.Параметры.Заполнить(ВыборкаПоСубконто);
			
			// Расшифровка
			ЗаполнитьПараметрыРасшифровки(ВыводимаяОбласть, ВыборкаПоСубконто, ОтборДляРасшифровки);
			
			ВыводимаяОбласть.Область(1,2).Отступ = Инд; // Уровень выделяется отступом
			
			Уровень = ВыборкаПоСубконто.Уровень();
			
			СтруктураПараметров.ДокументРезультат.Вывести(ВыводимаяОбласть, Уровень);
			// Вывод начального сальдо: конец
			
			
			// Вывод вложенных итогов
			ВыводСубконто(ВыборкаПоСубконто, Инд+1, СтруктураПараметров, БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки));
			// Вывод вложенных итогов: конец
			
			Если ВыборкаПоСубконто.ЕстьКоличественныеСчета Тогда
				ВыводимаяОбласть = СтруктураПараметров.ОбластьИтогСубконтоКоличество;
			Иначе
				ВыводимаяОбласть = СтруктураПараметров.ОбластьИтогСубконто;
			КонецЕсли;
			
			ВыводимаяОбласть.Параметры.Заполнить(ВыборкаПоСубконто);
			ЗаполнитьПараметрыРасшифровки(ВыводимаяОбласть, ВыборкаПоСубконто, ОтборДляРасшифровки);
			
			ВыводимаяОбласть.Область(1,2, ВыводимаяОбласть.ВысотаТаблицы, 2).Отступ = Инд; // Уровень выделяется отступом
			
			СтруктураПараметров.ДокументРезультат.Вывести(ВыводимаяОбласть, Уровень);
			// Вывод оборота и кон сальдо: конец
			
		КонецЦикла;
		
	Иначе
		
		ВывестиСчета(Выборка, СтруктураПараметров, БухгалтерскиеОтчеты.СоздатьКопиюСоответствияСтруктуры(ОтборДляРасшифровки));
		
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////
// ПРОЧИЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Обработчик события начала выбора значения субконто
//
// Параметры:
//	Элемент управления.
//	Стандартная обработка.
//
Процедура НачалоВыбораЗначенияСубконто(Элемент, СтандартнаяОбработка, ТипЗначенияПоля=Неопределено) Экспорт
	
	СписокПараметров = Новый Структура;
	СписокПараметров.Вставить("Дата",         ДатаКон);
	СписокПараметров.Вставить("СчетУчета",    Неопределено);
	СписокПараметров.Вставить("Номенклатура", Неопределено);
	СписокПараметров.Вставить("Склад", Неопределено);
	СписокПараметров.Вставить("Организация",  Организация);
	СписокПараметров.Вставить("Контрагент",  Неопределено);
	СписокПараметров.Вставить("ДоговорКонтрагента", Неопределено);
	СписокПараметров.Вставить("ЭтоНовыйДокумент", Ложь);
	
	// Поищем значения в отборе и в полях выбора субконто
	Для Инд=0 По ПостроительОтчета.Отбор.Количество()-1 Цикл
		
		СтрокаОтбора = ПостроительОтчета.Отбор[Инд];
		
		ЗначениеОтбора=?(ТипЗнч(СтрокаОтбора.Значение)<> Тип("СписокЗначений"), СтрокаОтбора.Значение, СтрокаОтбора.Значение[0].Значение);
		
		Если СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура.ТипЗначения Тогда
			СписокПараметров.Вставить("Номенклатура", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Склады.ТипЗначения Тогда
			СписокПараметров.Вставить("Склад", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты.ТипЗначения Тогда
			СписокПараметров.Вставить("Контрагент", ЗначениеОтбора);
		ИначеЕсли СтрокаОтбора.ТипЗначения = ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры.ТипЗначения Тогда
			СписокПараметров.Вставить("ДоговорКонтрагента", ЗначениеОтбора);
		КонецЕсли;
		
	КонецЦикла;
	
	БухгалтерскийУчет.ОбработатьВыборСубконто(Элемент, СтандартнаяОбработка, Организация, СписокПараметров, ТипЗначенияПоля);
	
КонецПроцедуры // ОбработкаВыбораСубконто()

// Заполнение настроек построителя отчетов
Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	МассивСубконто = Новый Массив;
	
	Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ОстаткиИОбороты.СуммаОборотКт КАК СуммаОборотКт";
	
	ТекстПоля = "";
	ТекстОтбор = "";
	ТекстИтоги = "";
	ТекстПорядок = "";
	
	МассивСубконто = Субконто.ВыгрузитьКолонку("ВидСубконто");
	
	КолвоСубконто = МассивСубконто.Количество();
	Для н=1 По КолвоСубконто Цикл
		Если Не ЗначениеЗаполнено(МассивСубконто[КолвоСубконто-н]) Тогда
			МассивСубконто.Удалить(КолвоСубконто-н);
		КонецЕсли;
	КонецЦикла;
	
	Для каждого стр Из Субконто Цикл
	
		Сч = стр.НомерСтроки;
		
		ТекстПоля = ТекстПоля + ", ОстаткиИОбороты.Субконто" +Сч+" КАК Субконто"+Сч;
		ТекстОтбор = ТекстОтбор + ", Субконто"+Сч+".*";
		ТекстИтоги = ТекстИтоги + ", Субконто"+Сч;
		ТекстПорядок = ТекстПорядок + ", ОстаткиИОбороты.Субконто" +Сч+".*";
	
	КонецЦикла;
	
	Если Не ПустаяСтрока(ТекстПоля) Тогда
		Текст = Текст +	"
		|{ВЫБРАТЬ
		|" + Сред(ТекстПоля, 2) + "}";
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ТекстОтбор) Тогда
		ТекстОтбор = "{"+Сред(ТекстОтбор, 2)+"}";
	КонецЕсли;
	
	Текст = Текст + "
	|ИЗ
	|	РегистрБухгалтерии."+ИмяРегистраБухгалтерии+".ОстаткиИОбороты(, , ПЕРИОД, , {Счет.*} , &МассивСубконто, "+ТекстОтбор+") КАК ОстаткиИОбороты
	|";
	
	Если Не ПустаяСтрока(ТекстПорядок) Тогда
		Текст = Текст + "
		|{УПОРЯДОЧИТЬ ПО 
		|" + Сред(ТекстПорядок, 2) + "}";
	КонецЕсли;
	
	Текст = Текст + "
	|ИТОГИ СУММА(СуммаОборотКт) ПО ОБЩИЕ";
	
	Если Не ПустаяСтрока(ТекстПоля) Тогда
		Текст = Текст + "
		|{ИТОГИ ПО
		|" + Сред(ТекстПоля, 2) + "}";
	КонецЕсли;
	
	ПостроительОтчета.Параметры.Вставить("ПустаяОрганизация", Справочники.Организации.ПустаяСсылка());
	
	ПостроительОтчета.Параметры.Вставить("МассивСубконто", МассивСубконто);
	
	ПостроительОтчета.Текст = Текст;
	
	Сч = 0;
	Для каждого Элемент Из МассивСубконто Цикл
		Сч = Сч+1;
		Поле = ПостроительОтчета.ДоступныеПоля.Найти("Субконто"+Сч);
		Поле.ТипЗначения = Элемент.ТипЗначения;
		Поле.Представление = Элемент.Наименование;
	КонецЦикла;

	// Определим признаки учета субконто, которые могут быть использованы
	ИмяПланаСчетов = Метаданные.РегистрыБухгалтерии[ИмяРегистраБухгалтерии].ПланСчетов.Имя;
	ЗапросСчета = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	МАКСИМУМ(Подзапрос.Валютный) КАК Валютный,
	|	МАКСИМУМ(Подзапрос.Количественный) КАК Количественный
	|ИЗ (ВЫБРАТЬ
	|	(ВС.Валютный И ВС.Ссылка.Валютный) Валютный,
	|	(ВС.Количественный И ВС.Ссылка.Количественный) Количественный
	|ИЗ
	|	ПланСчетов."+ИмяПланаСчетов+".ВидыСубконто КАК ВС	
	|ГДЕ
	|	ВС.ВидСубконто В(&ВидСубконто)) КАК Подзапрос
	|");
	
	МассивВидыСубконто = Субконто.ВыгрузитьКолонку("ВидСубконто");
	ЗапросСчета.УстановитьПараметр("ВидСубконто", МассивВидыСубконто);
	
	ВыборкаСчета = ЗапросСчета.Выполнить().Выбрать();
	
	ЕстьВалюта = Ложь;
	ЕстьКоличество = Ложь;
	Пока ВыборкаСчета.Следующий() Цикл
		ЕстьВалюта = ?(ВыборкаСчета.Валютный=Ложь, Ложь, Истина);
		ЕстьКоличество = ?(ВыборкаСчета.Количественный=Ложь, Ложь, Истина);
	КонецЦикла;
	
	Если ЕстьКоличество = Ложь Тогда
		ПоКоличеству = Ложь;
	Иначе
		ПоКоличеству = Истина;
	КонецЕсли;
	
	Если ЕстьВалюта = Ложь Тогда
		ПоВалютам = Ложь;
	КонецЕсли;
	
КонецПроцедуры

// Перезаполнение настроек построителя отчетов с сохранением пользовательских настроек
Процедура ПерезаполнитьНачальныеНастройки() Экспорт
	
	Настройки = ПостроительОтчета.ПолучитьНастройки();
	
	ЗаполнитьНачальныеНастройки();
	
	ПостроительОтчета.УстановитьНастройки(Настройки);
	
КонецПроцедуры

// Настраивает отчет по заданным параметрам (например, для расшифровки)
Процедура Настроить(СтруктураПараметров) Экспорт
	
	Параметры = Новый Соответствие;
	
	Для каждого Элемент Из СтруктураПараметров Цикл
		Параметры.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла; 

	Организация = Параметры["Организация"];
	ДатаНач = Параметры["ДатаНач"];
	ДатаКон = Параметры["ДатаКон"];
	
	Если Параметры["ЗаполнитьПоУмолчанию"] = Истина Тогда
		
		// Настраиваем по умолчанию
		
	Иначе
		
		ПоВалютам    = Параметры["ПоВалютам"];
		ПоКоличеству = Параметры["ПоКоличеству"];
		
		Субконто.Очистить();
		Для н=1 По 3 Цикл
			Если Параметры["ВидСубконто"+н]<>Неопределено Тогда
				Стр = Субконто.Добавить();
				Стр.ВидСубконто = Параметры["ВидСубконто"+н];
			КонецЕсли;
		КонецЦикла;
	
		ЗаполнитьНачальныеНастройки();
		
	КонецЕсли;
	
	СтрокиОтбора = Параметры["Отбор"];
	
	БухгалтерскиеОтчеты.ВосстановитьОтборПостроителяОтчетовПоПараметрам(ПостроительОтчета, СтрокиОтбора);

КонецПроцедуры

// Обработка расшифровки
//
// Параметры:
//	Нет.
//
Процедура ОбработкаРасшифровкиСтандартногоОтчета(Расшифровка) Экспорт
	
	СпособРасшифровки=Расшифровка["СпособРасшифровки"];
	
	Если СпособРасшифровки="Отчет" Тогда
		
		Отчет = Отчеты[Расшифровка["ИмяОбъекта"]].Создать();
		
		Отчет.Настроить(Расшифровка);
		
		ФормаОтчета = Отчет.ПолучитьФорму(, , Новый УникальныйИдентификатор());
		
		ФормаОтчета.ПоказыватьЗаголовок = Расшифровка["ПоказыватьЗаголовок"];
		
		ФормаОтчета.ОбновитьОтчет();
		
		ФормаОтчета.Открыть();

	КонецЕсли;
	
КонецПроцедуры // ОбработкаРасшифровкиСтандартногоОтчета()

// Получение номера субконто счета для известного вида субконто
//
// Параметры
//  ВидСубконто  – ПланВидовХарактеристикСсылка – Вид субконто, для которого необходимо определить порядковый номер
//  Счет         – ПланСчетовСсылка             – Счет, у которого ищется данный вид субконто
//  ВидыСубконто – Коллекция Видов Суб. счета   - Коллекция видов субконто данного счета, если не указана, то выбирается из базы
//
// Возвращаемое значение:
//   Число   – Порядковый номер вида субконто, 0 - если указанный вид субконто не найден у данного счета
//
Функция ПолучитьНомерСубконтоСчета(ВидСубконто, Счет, ВидыСубконто=Неопределено)

	Если ВидыСубконто=Неопределено Тогда
		ВидыСубконто = Счет.ВидыСубконто;
	КонецЕсли;
	
	НомерСубконто = 0;
	
	СтрокаВидаСубконто = ВидыСубконто.Найти(ВидСубконто, "ВидСубконто");
	
	Если СтрокаВидаСубконто <> Неопределено Тогда
		НомерСубконто = ВидыСубконто.Индекс(СтрокаВидаСубконто)+1;
	КонецЕсли;

	Возврат НомерСубконто;

КонецФункции // ПолучитьНомерСубконтоСчета()

//////////////////////////////////////////////////////////
// МОДУЛЬ ОБЪЕКТА
//


НП = Новый НастройкаПериода;
НП.ВариантНастройки = ВариантНастройкиПериода.Период;

ИмяРегистраБухгалтерии = "Хозрасчетный";

МаксКоличествоСубконто = Метаданные.ПланыСчетов[Метаданные.РегистрыБухгалтерии[ИмяРегистраБухгалтерии].ПланСчетов.Имя].МаксКоличествоСубконто;

ЕстьВалюта = Ложь;
ЕстьКоличество = Ложь;

МассивШиринКолонок = Новый Массив;
ШиринаТаблицы = 0;

кэшВидовСубконто = Новый Соответствие;

#КонецЕсли