#Если Клиент Тогда

Перем НП Экспорт;
Перем ИмяРегистраБухгалтерии Экспорт;


//////////////////////////////////////////////////////////
// ФОРМИРОВАНИЕ ЗАГОЛОВКА ОТЧЕТА
//

Функция ЗаголовокОтчета() Экспорт
	Возврат "Сводные проводки (международный учет)";
КонецФункции // ЗаголовокОтчета()

// Функция возвращает строку описания настроек отборов
//
// Параметры
//  Нет параметров
//
// Возвращаемое значение:
//   Строка   – Строка описания настроек, выводимая в шапку отчета
//
Функция ПолучитьОписаниеНастроек()
	
	СтрокаОписания = "";
	
	Если ПоВалюте Тогда
		СтрокаОписания = СтрокаОписания+?(ПустаяСтрока(СтрокаОписания),"","; ")+"Валюта="+Строка(Валюта);
	КонецЕсли;
	
	// добавь описание своих настроек
	
	СтрокаОписания = ?(ПустаяСтрока(СтрокаОписания),"фильтры не заданы",СтрокаОписания);
	
	Возврат СтрокаОписания;
	
КонецФункции // ПолучитьОписаниеНастроек()

// Выводит заголовок отчета
//
// Параметры:
//	Нет.
//
Функция СформироватьЗаголовок() Экспорт

	// Вывод заголовка, описателя периода и фильтров и заголовка
	Если ДатаНач = '00010101000000' И ДатаКон = '00010101000000' Тогда

		ОписаниеПериода     = "Период: без ограничения";

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
	ОбластьЗаголовок=Макет.Область("Заголовок");
	
	// После удаления областей нужно установить свойства ПоВыделеннымКолонкам
	Для Сч = 1 По ЗаголовокОтчета.ВысотаТаблицы-1 Цикл
		
		Макет.Область(ОбластьЗаголовок.Верх+Сч, 2, ОбластьЗаголовок.Верх+Сч, 2).РазмещениеТекста = ТипРазмещенияТекстаТабличногоДокумента.Переносить;
		Макет.Область(ОбластьЗаголовок.Верх+Сч, 2, ОбластьЗаголовок.Верх+Сч, ОбластьЗаголовок.Право).ПоВыделеннымКолонкам = Истина;
		
	КонецЦикла;
	
	ЗаголовокОтчета = Макет.ПолучитьОбласть("Заголовок");

	НазваниеОрганизации = Организация.НаименованиеПолное;
	Если ПустаяСтрока(НазваниеОрганизации) Тогда
		НазваниеОрганизации = Организация;
	КонецЕсли;
	
	ОписаниеНастроек = ПолучитьОписаниеНастроек();
	
	ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ЗаголовокОтчета.Параметры.ОписаниеПериода     = ОписаниеПериода;
	ЗаголовокОтчета.Параметры.ОписаниеНастроек    = ОписаниеНастроек;
	ЗаголовокОтчета.Параметры.Заголовок           = ЗаголовокОтчета();
	
	// Вывод списка фильтров:
	СтрОтбор = "";

	Если Не ПустаяСтрока(СтрОтбор) Тогда
		ОбластьОтбор = Макет.ПолучитьОбласть("СтрокаОтбор");
		ОбластьОтбор.Параметры.ТекстПроОтбор = "Отбор: " + СтрОтбор;
		ЗаголовокОтчета.Вывести(ОбластьОтбор);
	КонецЕсли;

	Возврат(ЗаголовокОтчета);

КонецФункции // СформироватьЗаголовок()


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
	
	СтруктураНастроек.Вставить("ДатаНач"    , ДатаНач);
	СтруктураНастроек.Вставить("ДатаКон"    , Макс(ДатаНач, ДатаКон));
	
	СтруктураНастроек.Вставить("Валюта"     , Валюта);
	СтруктураНастроек.Вставить("ПоВалюте"   , ПоВалюте);
	
	СтруктураНастроек.Вставить("ПоСубсчетам", ПоСубсчетам);
	СтруктураНастроек.Вставить("ПоДебетовым", ПоДебетовым);
	
	Возврат СтруктураНастроек;

КонецФункции // СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок)

// Восстановление значимых реквизитов отчета из структуры
//
// Параметры:
//    Структура   - структура, которая содержит значения реквизитов отчета
Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками) Экспорт

	Если ТипЗнч(СтруктураСНастройками) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("Организация", Организация);
	
	СтруктураСНастройками.Свойство("ДатаНач"    , ДатаНач);
	СтруктураСНастройками.Свойство("ДатаКон"    , ДатаКон);
	
	СтруктураСНастройками.Свойство("Валюта"     , Валюта);
	СтруктураСНастройками.Свойство("ПоВалюте"   , ПоВалюте);
	
	СтруктураСНастройками.Свойство("ПоСубсчетам", ПоСубсчетам);
	
	Если СтруктураСНастройками.Свойство("ПоДебетовым") Тогда
		
		СтруктураСНастройками.Свойство("ПоДебетовым", ПоДебетовым);
		
	Иначе
		
		ПоДебетовым = Истина;
	
	КонецЕсли;

КонецПроцедуры


//////////////////////////////////////////////////////////
// ПОСТРОЕНИЕ ОТЧЕТА
//

// Заполнение расшифровки, содержащей данные для всего отчета в целом
Процедура ЗаполнитьОбщуюРасшифровку(ДокументРезультат)

	Расшифровка = СформироватьСтруктуруДляСохраненияНастроек();
	Расшифровка.Удалить("Валюта");
	Расшифровка.Удалить("ПоВалюте");
	
	ДокументРезультат.Область(1,1).Расшифровка = Расшифровка;

КонецПроцедуры

// Формирование расшифровки для строки отчета
//
// Параметры
//  Выборка  – выборка – Выборка из результата запроса
//
// Возвращаемое значение:
//   СписокЗначение   – список значений с расшифровкой
//
Функция ПолучитьРасшифровкуДляСтроки(Выборка)

	струкРасшифровки = Новый Структура;
	струкРасшифровки.Вставить("ИмяОбъекта", "ОтчетПоПроводкам" + ИмяРегистраБухгалтерии);
	струкРасшифровки.Вставить("СчетДт", Выборка.СчетДт);
	струкРасшифровки.Вставить("СчетКт", Выборка.СчетКт);
	
	Если ЗначениеЗаполнено(Выборка.ВалютаДт) Тогда
		струкРасшифровки.Вставить("Валюта", Выборка.ВалютаДт);
		струкРасшифровки.Вставить("ПоВалюте", Истина);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Выборка.ВалютаКт) Тогда
		струкРасшифровки.Вставить("Валюта", Выборка.ВалютаКт);
		струкРасшифровки.Вставить("ПоВалюте", Истина);
	КонецЕсли;
	
	СписокРасшифровок = Новый СписокЗначений;
	СписокРасшифровок.Добавить(струкРасшифровки, "Отчет по проводкам "+Выборка.СчетДтКод+" - "+Выборка.СчетКтКод);

	Возврат СписокРасшифровок;
	
КонецФункции // ПолучитьРасшифровкуДляСтроки()

// Формирование текста запроса
//
// Параметры
//  Нет
//
// Возвращаемое значение:
//   Строка   – Текст запроса
//
Функция ПолучитьТекстЗапроса()

	ИмяПланаСчетов = Метаданные.РегистрыБухгалтерии[ИмяРегистраБухгалтерии].ПланСчетов.Имя;
	
	ТекстПорядка = ?(ПоДебетовым,
	"УПОРЯДОЧИТЬ ПО
	|	СчетаДт.Порядок,
	|	СчетаКт.Порядок",
	"УПОРЯДОЧИТЬ ПО
	|	СчетаКт.Порядок,
	|	СчетаДт.Порядок");
	
	ТекстИтогов = ?(ПоДебетовым,
	"	СчетДт ИЕРАРХИЯ,
	|	СчетКт ИЕРАРХИЯ",
	"	СчетКт ИЕРАРХИЯ,
	|	СчетДт ИЕРАРХИЯ");
	
	Текст = "
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СчетаДт.Ссылка КАК СчетДт,
	|	СчетаКт.Ссылка КАК СчетКт,
	|	СчетаДт.Валютный КАК СчетДтВалютный,
	|	СчетаКт.Валютный КАК СчетКтВалютный,
	|	ОборотыДтКт.СуммаОборот КАК Сумма,
	|	ОборотыДтКт.ВалютаДт,
	|	ПРЕДСТАВЛЕНИЕ(ОборотыДтКт.ВалютаДт) КАК ВалютаДтПредставление,
	|	ОборотыДтКт.ВалютнаяСуммаОборотДт КАК ВалютнаяСуммаДт,
	|	ОборотыДтКт.ВалютаКт,
	|	ПРЕДСТАВЛЕНИЕ(ОборотыДтКт.ВалютаКт) КАК ВалютаКтПредставление,
	|	ОборотыДтКт.ВалютнаяСуммаОборотКт КАК ВалютнаяСуммаКт,
	|	СчетаДт.Наименование КАК СчетДтНаименование,
	|	СчетаКт.Наименование КАК СчетКтНаименование,
	|	СчетаДт.Код КАК СчетДтКод,
	|	СчетаКт.Код КАК СчетКтКод
	|ИЗ
	|	РегистрБухгалтерии."+ИмяРегистраБухгалтерии+".ОборотыДтКт(&ДатаНач, &ДатаКон, Период, , , , , Организация = &Организация"+?(ПоВалюте, " И (ВалютаДт = &Валюта ИЛИ ВалютаКт = &Валюта)", "")+") КАК ОборотыДтКт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланСчетов."+ИмяПланаСчетов+" КАК СчетаДт
	|			ПО ОборотыДтКт.СчетДт = СчетаДт.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланСчетов."+ИмяПланаСчетов+" КАК СчетаКт
	|			ПО ОборотыДтКт.СчетКт = СчетаКт.Ссылка
	|"+ТекстПорядка+"
	|ИТОГИ
	|	СУММА(Сумма)
	|ПО
	|"+ТекстИтогов;

	Возврат Текст;
	
КонецФункции // ПолучитьТекстЗапроса()

// Вывод отчета в табличный документ
Процедура ВывестиОтчет(ДокументРезультат, Макет)

	ОблШапка = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОблСтрока = Макет.ПолучитьОбласть("Строка");
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = ПолучитьТекстЗапроса();
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Валюта", Валюта);
	Запрос.УстановитьПараметр("ДатаНач", ДатаНач);
	Запрос.УстановитьПараметр("ДатаКон", КонецДня(ДатаКон));
	
	Состояние("Выполнение запроса");
	Результат = Запрос.Выполнить();
	
	ДокументРезультат.Вывести(ОблШапка, 1);
	
	ПерваяВыборка = ?(ПоДебетовым,"СчетДт","СчетКт");
	ВтораяВыборка = ?(ПоДебетовым,"СчетКт","СчетДт");
	
	Выборка1 = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, ПерваяВыборка);
	Пока Выборка1.Следующий() Цикл
	
		Если Не ПоСубсчетам и Выборка1.Уровень()>0 Тогда
			Продолжить;
		КонецЕсли;
		
		Выборка2 = Выборка1.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, ВтораяВыборка, ПерваяВыборка);
		Пока Выборка2.Следующий() Цикл
			
			Если Не ПоСубсчетам и Выборка2.Уровень()>1 Тогда
				Продолжить;
			КонецЕсли;
			
			НетДетальных = Истина;
			ВыборкаДетальные = Выборка2.Выбрать(ОбходРезультатаЗапроса.Прямой);
			
			Пока ВыборкаДетальные.Следующий() Цикл
				
				Если (ВыборкаДетальные[ПерваяВыборка]<>Выборка1[ПерваяВыборка] или ВыборкаДетальные[ВтораяВыборка]<>Выборка2[ВтораяВыборка]) Тогда
					Продолжить;
				КонецЕсли;
				
				НетДетальных = Ложь;
				
				ОблСтрока.Параметры.Заполнить(ВыборкаДетальные);
				ОблСтрока.Параметры.Расшифровка = ПолучитьРасшифровкуДляСтроки(ВыборкаДетальные);
				ДокументРезультат.Вывести(ОблСтрока, Выборка1.Уровень());
				
			КонецЦикла;
			
			Если НетДетальных Тогда
				
				ОблСтрока.Параметры.Заполнить(Выборка2);
				ОблСтрока.Параметры.Расшифровка = ПолучитьРасшифровкуДляСтроки(Выборка2);
				ДокументРезультат.Вывести(ОблСтрока, Выборка1.Уровень());
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

// Формирование отчета
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Истина, ВысотаЗаголовка = 0) Экспорт

	Если ДатаНач > ДатаКон И ДатаКон <> '00010101000000' Тогда
		Предупреждение("Дата начала периода не может быть больше даты конца периода", 60);
		Возврат;
	КонецЕсли;

	ДокументРезультат.Очистить();

	Макет = ПолучитьМакет("Макет");

	// Вывод заголовка отчета
	ОбластьЗаголовка = СформироватьЗаголовок();
	ВысотаЗаголовка  = ОбластьЗаголовка.ВысотаТаблицы;
	
	ДокументРезультат.Вывести(ОбластьЗаголовка, 1);

	Если ЗначениеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;
	
	ЗаполнитьОбщуюРасшифровку(ДокументРезультат);
	
	/////////////////////////////////
	// здесь формируем отчет
	/////////////////////////////////
	ВывестиОтчет(ДокументРезультат, Макет);
	/////////////////////////////////
	
	// Зафиксируем заголовок отчета
	ДокументРезультат.ФиксацияСверху = ВысотаЗаголовка + 1;

	// Шапку таблицы печатаем на всех страницах
	ДокументРезультат.ПовторятьПриПечатиСтроки = ДокументРезультат.Область(ВысотаЗаголовка + 1,,ВысотаЗаголовка + 1);
	
	// Первую колонку не печатаем
	ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
	
	// Присвоим имя для сохранения параметров печати табличного документа
	ДокументРезультат.ИмяПараметровПечати = "СводныеПроводки "+ИмяРегистраБухгалтерии;

	УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(ДокументРезультат, ЗаголовокОтчета(), Строка(глЗначениеПеременной("глТекущийПользователь")));
	
КонецПроцедуры


//////////////////////////////////////////////////////////
// ПРОЧИЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Настраивает отчет по заданным параметрам (например, для расшифровки)
Процедура Настроить(СтруктураПараметров) Экспорт
	
	Параметры = Новый Соответствие;
	
	Для каждого Элемент Из СтруктураПараметров Цикл
		Параметры.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;

	Организация = Параметры["Организация"];
	ДатаНач = Параметры["ДатаНач"];
	ДатаКон = Параметры["ДатаКон"];
	
	СтрокиОтбора = Параметры["Отбор"];
	
	Если ТипЗнч(СтрокиОтбора) = Тип("Соответствие")
		ИЛИ ТипЗнч(СтрокиОтбора) = Тип("Структура") Тогда
	
		Для каждого ЭлементОтбора Из СтрокиОтбора Цикл
			
			Если ЭлементОтбора.Ключ = "Валюта" Тогда
				
				Валюта = ЭлементОтбора.Значение;
				ПоВалюте = ЗначениеЗаполнено(Валюта);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////
// МОДУЛЬ ОБЪЕКТА
//

НП = Новый НастройкаПериода;
НП.ВариантНастройки = ВариантНастройкиПериода.Период;

ИмяРегистраБухгалтерии = "Международный";

#КонецЕсли