////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Заполняет табличную часть документа "РабочиеМеста" по текущему состоянию работающих
//
Процедура ЗаполнитьТабличнуюЧастьРабочиеМестаПоТекущемуСостоянию() Экспорт

	РежимНабораПерсонала = Константы.РежимНабораПерсонала.Получить();
	
	Запрос = Новый Запрос;
	
	Если РежимНабораПерсонала = Перечисления.ВидыОрганизационнойСтруктурыПредприятия.ПоСтруктуреЮридическихЛиц Тогда
		Запрос.УстановитьПараметр("ВалютаРеглУчета",	глЗначениеПеременной("ВалютаРегламентированногоУчета"));
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РаботникиСрезПоследних.ПодразделениеОрганизации КАК Подразделение,
		|	РаботникиСрезПоследних.Должность.Должность КАК Должность,
		|	СУММА(РаботникиСрезПоследних.ЗанимаемыхСтавок) КАК Количество,
		|	&ВалютаРеглУчета КАК Валюта,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА ЛОЖЬ
		|		ИНАЧЕ ИСТИНА
		|	КОНЕЦ КАК ДолжностьЗаполнена,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА РаботникиСрезПоследних.Должность.Наименование
		|		ИНАЧЕ """"
		|	КОНЕЦ КАК ДолжностьОрганизации
		|ИЗ
		|	РегистрСведений.РаботникиОрганизаций.СрезПоследних КАК РаботникиСрезПоследних
		|ГДЕ
		|	РаботникиСрезПоследних.ПричинаИзмененияСостояния <> ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.Увольнение)
		|
		|СГРУППИРОВАТЬ ПО
		|	РаботникиСрезПоследних.ПодразделениеОрганизации,
		|	РаботникиСрезПоследних.Должность.Должность,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА РаботникиСрезПоследних.Должность.Наименование
		|		ИНАЧЕ """"
		|	КОНЕЦ";
		
	Иначе
		Запрос.УстановитьПараметр("ВалютаУпрУчета",	глЗначениеПеременной("ВалютаУправленческогоУчета"));
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	РаботникиСрезПоследних.Подразделение КАК Подразделение,
		|	РаботникиСрезПоследних.Должность.Должность КАК Должность,
		|	СУММА(РаботникиСрезПоследних.ЗанимаемыхСтавок) КАК Количество,
		|	&ВалютаУпрУчета КАК Валюта,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА ЛОЖЬ
		|		ИНАЧЕ ИСТИНА
		|	КОНЕЦ КАК ДолжностьЗаполнена,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА РаботникиСрезПоследних.Должность.Наименование
		|		ИНАЧЕ """"
		|	КОНЕЦ КАК ДолжностьОрганизации
		|ИЗ
		|	РегистрСведений.Работники.СрезПоследних КАК РаботникиСрезПоследних
		|ГДЕ
		|	РаботникиСрезПоследних.ПричинаИзмененияСостояния <> ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.Увольнение)
		|
		|СГРУППИРОВАТЬ ПО
		|	РаботникиСрезПоследних.Подразделение,
		|	РаботникиСрезПоследних.Должность.Должность,
		|	ВЫБОР
		|		КОГДА РаботникиСрезПоследних.Должность.Должность = ЗНАЧЕНИЕ(Справочник.Должности.ПустаяСсылка)
		|			ТОГДА РаботникиСрезПоследних.Должность.Наименование
		|		ИНАЧЕ """"
		|	КОНЕЦ";
		
	КонецЕсли;
	
	РабочиеМеста.Очистить();
	
	МассивДолжностейСОшибками = Новый Массив;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ДолжностьЗаполнена Тогда
			ЗаполнитьЗначенияСвойств(РабочиеМеста.Добавить(), Выборка);
		Иначе
			Если МассивДолжностейСОшибками.Найти(Выборка.ДолжностьОрганизации) = Неопределено Тогда
				МассивДолжностейСОшибками.Добавить(Выборка.ДолжностьОрганизации);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если МассивДолжностейСОшибками.Количество() > 0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Для следующих должностей не указана должность для набора персонала! Рабочие места по этим должностям не могут быть заполнены:");
	КонецЕсли;
	Для Каждого ТекущийЭлемент Из МассивДолжностейСОшибками Цикл
		ОбщегоНазначения.СообщитьОбОшибке(ТекущийЭлемент);
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Формирует запрос по шапке документа
//
// Параметры: 
//  Режим - режим проведения
//
// Возвращаемое значение:
//  Результат запроса
//
Функция СформироватьЗапросПоШапке(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка",	Ссылка);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	ИзменениеКадровогоПлана.ДатаИзменений,
	|	ИзменениеКадровогоПлана.Ссылка,
	|	Константы.РежимНабораПерсонала
	|ИЗ
	|	Документ.ИзменениеКадровогоПлана КАК ИзменениеКадровогоПлана,
	|	Константы КАК Константы
	|ГДЕ
	|	ИзменениеКадровогоПлана.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();
	
КонецФункции // СформироватьЗапросПоШапке()

// Формирует запрос по таблице "Штатные единицы" документа
//
// Параметры: 
//  Режим - режим проведения
//
// Возвращаемое значение:
//  Результат запроса
//
Функция СформироватьЗапросПоРабочиеМеста(ВыборкаПоШапкеДокумента, Режим)
	
	Запрос = Новый Запрос;
	
	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка",			Ссылка);
	Запрос.УстановитьПараметр("РежимНабораПерсонала",	ВыборкаПоШапкеДокумента.РежимНабораПерсонала);

	Запрос.Текст =
	"ВЫБРАТЬ
	|	""РабочиеМеста"" КАК ВидСтрокиЗапроса,
	|	Док.НомерСтроки КАК НомерСтроки,
	|	Док.Подразделение КАК Подразделение,
	|	Док.Должность,
	|	Док.Количество,
	|	NULL КАК КонфликтныйДокумент
	|ИЗ
	|	Документ.ИзменениеКадровогоПлана.РабочиеМеста КАК Док
	|ГДЕ
	|	Док.Ссылка = &ДокументСсылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	""КонфликтныйДокумент"",
	|	ИзменениеКадровогоПланаРабочиеМеста.НомерСтроки,
	|	NULL,
	|	NULL,
	|	NULL,
	|	КадровыйПлан.Регистратор.Представление
	|ИЗ
	|	Документ.ИзменениеКадровогоПлана.РабочиеМеста КАК ИзменениеКадровогоПланаРабочиеМеста
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.КадровыйПлан КАК КадровыйПлан
	|		ПО ИзменениеКадровогоПланаРабочиеМеста.Должность = КадровыйПлан.Должность
	|			И ИзменениеКадровогоПланаРабочиеМеста.Ссылка.ДатаИзменений = КадровыйПлан.Период
	|			И (ВЫБОР
	|				КОГДА &РежимНабораПерсонала = ЗНАЧЕНИЕ(Перечисление.ВидыОрганизационнойСтруктурыПредприятия.ПоСтруктуреЮридическихЛиц)
	|					ТОГДА ИзменениеКадровогоПланаРабочиеМеста.Подразделение = КадровыйПлан.ПодразделениеОрганизации
	|				ИНАЧЕ ИзменениеКадровогоПланаРабочиеМеста.Подразделение = КадровыйПлан.Подразделение
	|			КОНЕЦ)
	|ГДЕ
	|	ИзменениеКадровогоПланаРабочиеМеста.Ссылка = &ДокументСсылка";
	
	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоРабочиеМеста()

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизтов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверка выполняется по выборке из результата запроса по шапке,
// все проверяемые реквизиты должны быть включены в выборку по шапке.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента	- выборка из результата запроса по шапке документа,
//  Отказ 					- флаг отказа в проведении.
//	Заголовок				- Заголовок для сообщений об ошибках проведения
//
Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок)
	
	// ДатаИзменений
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.ДатаИзменений) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана дата изменений!", Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения реквизитов в строке ТЧ "Штатные единицы" документа.
// Если какой-то из реквизтов, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверка выполняется по выборке из результата запроса по строке ТЧ документа,
// все проверяемые реквизиты должны быть включены в выборку.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента		- выборка из результата запроса по шапке документа,
//  ВыборкаПоСтрокамДокумента	- спозиционированная на определеной строке выборка 
//  							  из результата запроса по строке ТЧ, 
//  Отказ 						- флаг отказа в проведении.
//	Заголовок				- Заголовок для сообщений об ошибках проведения
//
Процедура ПроверитьЗаполнениеСтрокиРабочегоМеста(ВыборкаПоШапкеДокумента, ВыборкаПоСтрокамДокумента, Отказ, Заголовок)

	СтрокаНачалаСообщенияОбОшибке = "В строке номер """+ СокрЛП(ВыборкаПоСтрокамДокумента.НомерСтроки) +
									""" табл. части ""Рабочие места"": ";

	Если ВыборкаПоСтрокамДокумента.ВидСтрокиЗапроса = "РабочиеМеста" Тогда
		
		// Подразделение
		Если НЕ ЗначениеЗаполнено(ВыборкаПоСтрокамДокумента.Подразделение) Тогда
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + "не выбрано подразделение!", Отказ, Заголовок);
		КонецЕсли;
		
		// Должность
		Если НЕ ЗначениеЗаполнено(ВыборкаПоСтрокамДокумента.Должность) Тогда
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + "не выбрана должность!", Отказ, Заголовок);
		КонецЕсли;
		
	Иначе // "КонфликтныйДокумент"

		// противоречие другим документам "Изменение кадрового плана"
		СтрокаСообщениеОбОшибке = "дата изменения документа противоречит документу " + Символы.ПС + Символы.Таб + ВыборкаПоСтрокамДокумента.КонфликтныйДокумент + "!"; 
		ОбщегоНазначения.СообщитьОбОшибке(СтрокаНачалаСообщенияОбОшибке + СтрокаСообщениеОбОшибке, Отказ, Заголовок);

	КонецЕсли
	
КонецПроцедуры // ПроверитьЗаполнениеСтрокиРабочегоМеста()

// По строке выборки результата запроса по документу формируем движения по регистрам
//
// Параметры: 
//  ВыборкаПоШапкеДокумента                - выборка из результата запроса по шапке документа,
//  СтруктураПроведенияПоРегистрамСведений - структура, содержащая имена регистров 
//                                           сведений по которым надо проводить документ,
//  СтруктураПараметров                    - структура параметров проведения,
//
// Возвращаемое значение:
//  Нет.
//
Процедура ДобавитьСтрокуВШтатноеРасписание(ВыборкаПоШапкеДокумента, ВыборкаПоСтрокамДокумента, СтруктураПараметров = "")

	Движение = Движения.КадровыйПлан.Добавить();
	
	// Свойства
	Движение.Период							= ВыборкаПоШапкеДокумента.ДатаИзменений;
	
	// Измерения
	Если ВыборкаПоШапкеДокумента.РежимНабораПерсонала = Перечисления.ВидыОрганизационнойСтруктурыПредприятия.ПоСтруктуреЮридическихЛиц Тогда
		Движение.ПодразделениеОрганизации	= ВыборкаПоСтрокамДокумента.Подразделение;
	Иначе
		Движение.Подразделение				= ВыборкаПоСтрокамДокумента.Подразделение;
	КонецЕсли;
	Движение.Должность						= ВыборкаПоСтрокамДокумента.Должность;
	
	// Ресурсы
	Движение.Количество						= ВыборкаПоСтрокамДокумента.Количество;
		
КонецПроцедуры // ДобавитьСтрокуВШтатноеРасписание

///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	РезультатЗапросаПоШапке = СформироватьЗапросПоШапке(Режим);
	// Получим реквизиты шапки из запроса
	ВыборкаПоШапкеДокумента = РезультатЗапросаПоШапке.Выбрать();

	Если ВыборкаПоШапкеДокумента.Следующий() Тогда

		//Надо позвать проверку заполнения реквизитов шапки
		ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок);

		// Движения стоит добавлять, если в проведении еще не отказано (отказ = ложь)
		Если НЕ Отказ Тогда

			РезультатЗапросаПоРабочиеМеста = СформироватьЗапросПоРабочиеМеста(ВыборкаПоШапкеДокумента, Режим);

			// В циклах по строкам табличных частей будем добавлять информацию в движения регистров
			ВыборкаПоРабочиеМеста = РезультатЗапросаПоРабочиеМеста.Выбрать();
			Пока ВыборкаПоРабочиеМеста.Следующий() Цикл 

				// проверим очередную строку табличной части
				ПроверитьЗаполнениеСтрокиРабочегоМеста(ВыборкаПоШапкеДокумента, ВыборкаПоРабочиеМеста, Отказ, Заголовок);

				// Движения стоит записывать, если в проведении еще не отказано (отказ =ложь)
				Если Не Отказ Тогда
					ДобавитьСтрокуВШтатноеРасписание(ВыборкаПоШапкеДокумента, ВыборкаПоРабочиеМеста);
				КонецЕсли;

			КонецЦикла;
			
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
