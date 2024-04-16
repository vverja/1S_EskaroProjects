#Если Клиент Тогда
// Настройка периода
Перем НП Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Ложь, ВысотаЗаголовка = 0, ТолькоЗаголовок = Ложь) Экспорт

	// не выводим общие
	ОбщийОтчет.мСтруктураНевыводимыхГруппировок.Вставить("Общие", 1);

	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаНач"              , ОбщийОтчет.ДатаНач);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаКон"              , КонецДня(ОбщийОтчет.ДатаКон));
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СостояниеВвода"       , Перечисления.СостоянияОС.ВведеноВЭксплуатацию);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СостояниеСнятияСУчета", Перечисления.СостоянияОС.СнятоСУчета);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СчетУчета"            , ПланыСчетов.Налоговый.ОсновныеСредстваУчетПоГруппам);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СчетВР"               , ПланыСчетов.Налоговый.ВаловыеРасходы); 
	
	ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке = Истина;
	
	ОбщийОтчет.СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок);

КонецПроцедуры // СформироватьОтчет()

// Процедура - заполняет начальные настройки отчета
//
Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	ПостроительОтчета = ОбщийОтчет.ПостроительОтчета;
	
	Текст = 
	"ВЫБРАТЬ
	|	Стоимость.Организация                                   КАК Организация,
	|	ПРЕДСТАВЛЕНИЕ(Стоимость.Организация),
	|	Стоимость.Субконто1                                     КАК ВидНалоговойДеятельности,
	|	ПРЕДСТАВЛЕНИЕ(Стоимость.Субконто1)                      КАК ВидНалоговойДеятельностиПредставление,
	|	Стоимость.Субконто3                                     КАК НалоговаяГруппаОС,
	|	ПРЕДСТАВЛЕНИЕ(Стоимость.Субконто3)                      КАК НалоговаяГруппаОСПредставление,
	|	СУММА(ПервоначальныеСведения.ПервоначальнаяСтоимостьНУ) КАК ПервоначальнаяСтоимость,
	|	СУММА(Стоимость.СуммаНачальныйОстаток)                  КАК СтоимостьНачальныйОстаток,
	|	СУММА(Стоимость.СуммаОборотДт)                          КАК СтоимостьОборотДт,
	|	СУММА(Стоимость.СуммаОборотКт)                          КАК СтоимостьСАмортизациейОборотКт,
	|	СУММА(Стоимость.СуммаОборот)                            КАК СтоимостьСАмортизациейОборот,
	|	СУММА(Стоимость.СуммаКонечныйОстаток)                   КАК СтоимостьКонечныйОстаток,
	|	СУММА(Амортизация.СуммаОборот)                          КАК АмортизацияОборот,
	|	СУММА(Стоимость.СуммаОборот) 
	|		- ЕСТЬNULL(СУММА(Амортизация.СуммаОборот), 0)       КАК СтоимостьОборот,
	|	СУММА(Стоимость.СуммаОборотКт) 
	|		- ЕСТЬNULL(СУММА(Амортизация.СуммаОборот), 0)       КАК СтоимостьОборотКт
	|{ВЫБРАТЬ
	|	Организация.*,
	|	ВидНалоговойДеятельности.*,
	|	НалоговаяГруппаОС.*}
	|ИЗ
	|	РегистрБухгалтерии.Налоговый.ОстаткиИОбороты(&ДатаНач, &ДатаКон, , ,
	|	                   Счет = &СчетУчета, , {Субконто3 КАК НалоговаяГруппаОС,
	|	                   Организация.* КАК Организация, Субконто3 КАК ВидНалоговойДеятельности}) КАК Стоимость
	|		ЛЕВОЕ СОЕДИНЕНИЕ 
	|			(ВЫБРАТЬ
	|				ПервоначальныеСведения.Организация                      КАК Организация,
	|				НалоговыеНазначенияОС.НалоговоеНазначение.ВидНалоговойДеятельности      КАК ВидНалоговойДеятельности,
	|				ПервоначальныеСведения.НалоговаяГруппаОС                КАК НалоговаяГруппаОС,
	|				СУММА(ПервоначальныеСведения.ПервоначальнаяСтоимостьНУ) КАК ПервоначальнаяСтоимостьНУ
	|			ИЗ
	|				РегистрСведений.ПервоначальныеСведенияОСНалоговыйУчет.СрезПоследних(&ДатаКон, 
	|				                {НалоговаяГруппаОС, Организация.* КАК Организация}) КАК ПервоначальныеСведения
	|					ЛЕВОЕ СОЕДИНЕНИЕ 
	|						РегистрСведений.НалоговыеНазначенияОС.СрезПоследних(
	|						                &ДатаКон, {Организация.* КАК Организация}) КАК НалоговыеНазначенияОС
	|					ПО ПервоначальныеСведения.Организация = НалоговыеНазначенияОС.Организация
	|						И ПервоначальныеСведения.ОсновноеСредство = НалоговыеНазначенияОС.ОсновноеСредство
	|		
	|			СГРУППИРОВАТЬ ПО
	|				ПервоначальныеСведения.Организация,
	|				НалоговыеНазначенияОС.НалоговоеНазначение.ВидНалоговойДеятельности,
	|				ПервоначальныеСведения.НалоговаяГруппаОС) КАК ПервоначальныеСведения
	|		ПО Стоимость.Организация = ПервоначальныеСведения.Организация
	|			И Стоимость.Субконто1 = ПервоначальныеСведения.ВидНалоговойДеятельности
	|			И Стоимость.Субконто3 = ПервоначальныеСведения.НалоговаяГруппаОС
	|		ЛЕВОЕ СОЕДИНЕНИЕ 
	|			РегистрБухгалтерии.Налоговый.ОборотыДтКт(&ДатаНач, &ДатаКон, ,
	|			                   СчетДт = &СчетВР, , СчетКт = &СчетУчета, , 
	|			                   {СубконтоКт3 КАК НалоговаяГруппаОС, 
	|			                   Организация.* КАК Организация}) КАК Амортизация
	|		ПО Стоимость.Организация = Амортизация.Организация
	|			И Стоимость.Субконто1 = Амортизация.СубконтоКт1
	|			И Стоимость.Субконто3 = Амортизация.СубконтоКт3
	|
	|СГРУППИРОВАТЬ ПО
	|	Стоимость.Организация,
	|	Стоимость.Субконто1,
	|	Стоимость.Субконто3
	|{УПОРЯДОЧИТЬ ПО
	|	Организация,
	|	ВидНалоговойДеятельности,
	|	НалоговаяГруппаОС,
	|	ПервоначальнаяСтоимость,
	|	СтоимостьНачальныйОстаток,
	|	СтоимостьОборотДт,
	|	СтоимостьСАмортизациейОборотКт,
	|	СтоимостьСАмортизациейОборот,
	|	СтоимостьКонечныйОстаток,
	|	АмортизацияОборот,
	|	СтоимостьОборот,
	|	СтоимостьОборотКт}
	|ИТОГИ
	|	СУММА(ПервоначальнаяСтоимость),
	|	СУММА(СтоимостьНачальныйОстаток),
	|	СУММА(СтоимостьОборотДт),
	|	СУММА(СтоимостьСАмортизациейОборотКт),
	|	СУММА(СтоимостьСАмортизациейОборот),
	|	СУММА(СтоимостьКонечныйОстаток),
	|	СУММА(АмортизацияОборот),
	|	СУММА(СтоимостьОборот),
	|	СУММА(СтоимостьОборотКт)
	|ПО
	|	ОБЩИЕ,
	|	Организация,
	|	ВидНалоговойДеятельности
	|{ИТОГИ ПО
	|	Организация,
	|	ВидНалоговойДеятельности,
	|	НалоговаяГруппаОС}
	|АВТОУПОРЯДОЧИВАНИЕ";
	
	СтруктураПредставлениеПолей = Новый Структура;
	СтруктураПредставлениеПолей.Вставить( "ВидНалоговойДеятельности", "Вид налоговой деятельности");
	СтруктураПредставлениеПолей.Вставить( "НалоговаяГруппаОС",        "Налоговая группа");
	
	СтруктураПредставлениеПолей.Вставить( "ПервоначальнаяСтоимость",        "Первоначальная стоимость");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьНачальныйОстаток",      "Стоимость на начало периода");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьОборотДт",              "Стоимость (приход)");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьСАмортизациейОборотКт", "Стоимость с Аморт.(расход)");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьСАмортизациейОборот",   "Изменение стоимости ОС с уч. аморт.");
	СтруктураПредставлениеПолей.Вставить( "АмортизацияОборот",              "Амортизация за период");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьОборотКт",              "Стоимость (расход)");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьОборот",                "Изменение стоимости");
	СтруктураПредставлениеПолей.Вставить( "СтоимостьКонечныйОстаток",       "Стоимость на конец периода");
	
	ПостроительОтчета.Текст = Текст;
		
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(СтруктураПредставлениеПолей, ПостроительОтчета);
	УправлениеОтчетами.ОчиститьДополнительныеПоляПостроителя(ПостроительОтчета);
	
	ОбщийОтчет.ЗаполнитьПоказатели( "ПервоначальнаяСтоимость",        "Первоначальная стоимость",            Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьНачальныйОстаток",      "Стоимость на начало периода",         Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьОборотДт",              "Стоимость (приход)",                  Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьСАмортизациейОборотКт", "Стоимость с Аморт.(расход)",          Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьСАмортизациейОборот",   "Изменение стоимости ОС с уч. аморт.", Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "АмортизацияОборот",              "Амортизация за период",               Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьОборотКт",              "Стоимость (расход)",                  Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьОборот",                "Изменение стоимости",                 Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьКонечныйОстаток",       "Стоимость на конец периода",          Истина, "ЧЦ=15; ЧДЦ=2");
	
	
	МассивОтбора = Новый Массив;
	МассивОтбора.Добавить("Организация");
	МассивОтбора.Добавить("НалоговаяГруппаОС");
	
	УправлениеОтчетами.ЗаполнитьОтбор(МассивОтбора, ПостроительОтчета);
	
	ОбщийОтчет.ВыводитьПоказателиВСтроку = Истина;
	ОбщийОтчет.РаскрашиватьИзмерения     = Истина;
	
КонецПроцедуры // ЗаполнитьНачальныеНастройки()

// Читает свойство Построитель отчета
//
// Параметры
//	Нет
//
Функция ПолучитьПостроительОтчета() Экспорт

	Возврат ОбщийОтчет.ПолучитьПостроительОтчета();

КонецФункции // ПолучитьПостроительОтчета()

// Настраивает отчет по переданной структуре параметров
//
// Параметры:
//	Нет.
//
Процедура Настроить(Параметры) Экспорт

	ОбщийОтчет.Настроить(Параметры, ЭтотОбъект);

КонецПроцедуры // Настроить()

// Возвращает основную форму отчета, связанную с данным экземпляром отчета
//
// Параметры
//	Нет
//
Функция ПолучитьОсновнуюФорму() Экспорт
	
	ОснФорма = ПолучитьФорму();
	ОснФорма.ОбщийОтчет = ОбщийОтчет;
	ОснФорма.ЭтотОтчет  = ЭтотОбъект;
	
	Возврат ОснФорма;
	
КонецФункции // ПолучитьОсновнуюФорму()

// Возвращает форму настройки 
//
// Параметры:
//	Нет.
//
// Возвращаемое значение:
//	
//
Функция ПолучитьФормуНастройки() Экспорт
	
	ФормаНастройки = ОбщийОтчет.ПолучитьФорму("ФормаНастройка");
	Возврат ФормаНастройки;
	
КонецФункции // ПолучитьФормуНастройки()

// Процедура обработки расшифровки
//
// Параметры:
//	Нет.
//
Процедура ОбработкаРасшифровки(РасшифровкаСтроки, ПолеТД, ВысотаЗаголовка, СтандартнаяОбработка) Экспорт
	
	// Добавление расшифровки из колонки
	Если ТипЗнч(РасшифровкаСтроки) = Тип("Структура") Тогда
		
		// Расшифровка колонки находится в заголовке колонки
		РасшифровкаКолонки = ПолеТД.Область(ВысотаЗаголовка+2, ПолеТД.ТекущаяОбласть.Лево).Расшифровка;

		Расшифровка = Новый Структура;

		Для каждого Элемент Из РасшифровкаСтроки Цикл
			Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
		КонецЦикла;

		Если ТипЗнч(РасшифровкаКолонки) = Тип("Структура") Тогда

			Для каждого Элемент Из РасшифровкаКолонки Цикл
				Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
			КонецЦикла;

		КонецЕсли; 

		ОбщийОтчет.ОбработкаРасшифровкиСтандартногоОтчета(Расшифровка, СтандартнаяОбработка, ЭтотОбъект);

	КонецЕсли;
	
КонецПроцедуры // ОбработкаРасшифровки()

// Формирует структуру, в которую складываются настройки
//
Функция СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок) Экспорт
	
	СтруктураНастроек = Новый Структура;
	
	ОбщийОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураНастроек, ПоказыватьЗаголовок);
	
	Возврат СтруктураНастроек;
	
КонецФункции

// Заполняет настройки из структуры - кроме состояния панели "Отбор"
//
Процедура ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки, ПоказыватьЗаголовок, Отчет=Неопределено) Экспорт
	
	// Если отчет, вызвавший процедуру, не передан, то считаем, что ее вызвал этот отчет
	Если Отчет = Неопределено Тогда
		Отчет = ЭтотОбъект;
	КонецЕсли;

	ОбщийОтчет.ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки, ПоказыватьЗаголовок, Отчет);
	
КонецПроцедуры

ОбщийОтчет.ИмяРегистра = "Налоговый";
ОбщийОтчет.мНазваниеОтчета = "Ведомость амортизации групп ОС (налоговый учет)";
ОбщийОтчет.мВыбиратьИмяРегистра = Ложь;
ОбщийОтчет.мРежимВводаПериода = 0;
ОбщийОтчет.мВыбиратьИспользованиеСвойств = Ложь;

#КонецЕсли
