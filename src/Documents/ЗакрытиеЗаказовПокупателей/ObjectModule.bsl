Перем мУдалятьДвижения;

Перем мВалютаРегламентированногоУчета Экспорт;
Перем СтруктураШапкиДокумента;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
	
// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
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
			Возврат
		КонецЕсли; 
		
	КонецЕсли;

	УниверсальныеМеханизмы.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, ОбщегоНазначения.СформироватьЗаголовокДокумента(ЭтотОбъект), Ссылка);

КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура;

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТаре  - результат запроса по табличной части "ВозвратнаяТара",
//  ВыборкаПоШапкеДокумента - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблица значений.
//
// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение, не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("ВидОперации");

	// Если в табличной части по заказу ведется обособленный учет,
	// то обязательно заполнение реквизита Организация
	Для каждого СтрокаТЧ Из Заказы Цикл
		Если СтрокаТЧ.ЗаказПокупателя.ДоговорКонтрагента.ОбособленныйУчетТоваровПоЗаказамПокупателей Тогда
			СтруктураОбязательныхПолей.Вставить("Организация");
			Прервать;
		КонецЕсли
	КонецЦикла;
	
	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
// Параметры: 
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  ВыборкаПоШапкеДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиЗаказы(ТаблицаПоТоварам, ВыборкаПоШапкеДокумента, 
	                                              Отказ, Заголовок)

	ПроверитьОрганизацию = НЕ Организация.Пустая();
	
	Для Каждого СтрокаТЧ Из Заказы Цикл
		// Проверим даты Заказов, они не должны быть больше даты документа
		Если СтрокаТЧ.ЗаказПокупателя.Дата > Дата Тогда
			СтрокаСообщения = "Дата и время Заказа в строке " + СокрЛП(СтрокаТЧ.НомерСтроки) + " больше даты и времени документа!";			
			ОбщегоНазначения.СообщитьОбОшибке(СтрокаСообщения, Отказ, Заголовок);
		КонецЕсли;
		
		// Проверим организацию Заказов, она не должна отличаться от организации документа
		Если ПроверитьОрганизацию Тогда
			Если СтрокаТЧ.ЗаказПокупателя.Организация <> Организация Тогда
				СтрокаСообщения = "Организация Заказа в строке " + СокрЛП(СтрокаТЧ.НомерСтроки) + " отличается от организации документа!";
				ОбщегоНазначения.СообщитьОбОшибке(СтрокаСообщения, Отказ, Заголовок);
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("ЗаказПокупателя");

	// Теперь вызовем общую процедуру проверки.
	ЗаполнениеДокументов.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Заказы", СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры: 
//  РежимПроведения           - режим проведения документа (оперативный или неоперативный),
//  ВыборкаПоШапкеДокумента   - выборка из результата запроса по шапке документа,
//  ТаблицаПоТоварам          - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  ТаблицаПоТаре             - таблица значений, содержащая данные для проведения и проверки ТЧ "Возвратная тара",
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, ВыборкаПоШапкеДокумента, ТаблицаПоЗаказамПокупателей, ТаблицаПоРазмещению, 
								ТаблицаПоЗаказамПоставщикам, ТаблицаПоРезервам, ТаблицаПоРасчетам, Отказ, Заголовок)
								
	ДвиженияПоРегистрамУпр(РежимПроведения, ВыборкаПоШапкеДокумента,	ТаблицаПоЗаказамПокупателей, ТаблицаПоРазмещению, 
								ТаблицаПоЗаказамПоставщикам, ТаблицаПоРезервам, ТаблицаПоРасчетам, Отказ, Заголовок);
								
	ДвиженияПоРегиструСписанныеТовары(РежимПроведения, ТаблицаПоЗаказамПокупателей, Отказ, Заголовок);
	
	// Заполним таблицу регистрации в последовательностях по регл учету
	ТаблицаОтраженияВПоследовательностяхРегл = Новый ТаблицаЗначений;
	ТаблицаОтраженияВПоследовательностяхРегл.Колонки.Добавить("Организация");
	ТаблицаОтраженияВПоследовательностяхРегл.Колонки.Добавить("ОтражатьВРеглУчете", Новый ОписаниеТипов("Булево"));
	
	Для Каждого Строка Из ТаблицаПоЗаказамПокупателей Цикл
		Если ЗначениеЗаполнено(Строка.Организация) И Строка.ОбособленныйУчетТоваровПоЗаказамПокупателей Тогда
			
			НайдСтрока = ТаблицаОтраженияВПоследовательностяхРегл.Найти(Строка.Организация, "Организация");
			Если НайдСтрока=Неопределено Тогда
				СтрокаРегистрации=ТаблицаОтраженияВПоследовательностяхРегл.Добавить();
				СтрокаРегистрации.Организация = Строка.Организация;
			Иначе
				СтрокаРегистрации=НайдСтрока;
			КонецЕсли;
			СтрокаРегистрации.ОтражатьВРеглУчете 	  = СтрокаРегистрации.ОтражатьВРеглУчете  ИЛИ Строка.ОбособленныйУчетТоваровПоЗаказамПокупателей;
		КонецЕсли;
	КонецЦикла;
		
	Для Каждого Строка Из ТаблицаОтраженияВПоследовательностяхРегл Цикл
		
		УправлениеЗапасами.ЗарегистрироватьДокументВПоследовательностяхПартионногоУчета(ЭтотОбъект, Дата, Строка.Организация,истина,Строка.ОтражатьВРеглУчете,СтруктураШапкиДокумента.СпособВеденияПартионногоУчетаПоОрганизации);
		 
	КонецЦикла;
	
	УправлениеЗапасамиПартионныйУчет.ДвижениеПартийТоваров(Ссылка, Движения.СписанныеТовары.Выгрузить());
	
КонецПроцедуры

Процедура ДвиженияПоРегиструСписанныеТовары(РежимПроведения, ТаблицаЗакрываемыеЗаказы, Отказ, Заголовок)
	
	Если СтруктураШапкиДокумента.ИспользоватьРАУЗ Тогда 
		Возврат; 
	КонецЕсли;	
	
	Если ТаблицаЗакрываемыеЗаказы.Найти(истина,"ОбособленныйУчетТоваровПоЗаказамПокупателей")=неопределено Тогда
		Возврат;
	КонецЕсли;
	
	НаборДвижений = Движения.СписанныеТовары;
	
	Сч=0;
	
	ТаблицаСРаздельнымУчетом = ТаблицаЗакрываемыеЗаказы.Скопировать();
	ТаблицаСРаздельнымУчетом.Свернуть("ОбособленныйУчетТоваровПоЗаказамПокупателей,Номенклатура,ХарактеристикаНоменклатуры,Организация,ЗаказПокупателя");
	
	Для каждого ВыборкаЗакрываемыеЗаказы Из ТаблицаСРаздельнымУчетом Цикл
		Если не ВыборкаЗакрываемыеЗаказы.ОбособленныйУчетТоваровПоЗаказамПокупателей Тогда
			Продолжить;
		КонецЕсли;
		НоваяСтрока = НаборДвижений.Добавить();
		НоваяСтрока.НомерСтрокиДокумента=Сч;
		НоваяСтрока.Период = Дата;
		НоваяСтрока.Регистратор = Ссылка;
		НоваяСтрока.Номенклатура = ВыборкаЗакрываемыеЗаказы.Номенклатура;
		НоваяСтрока.ХарактеристикаНоменклатуры = ВыборкаЗакрываемыеЗаказы.ХарактеристикаНоменклатуры;
		НоваяСтрока.ОтражатьВУправленческомУчете = Истина;
		НоваяСтрока.ОтражатьВБухгалтерскомУчете = ВыборкаЗакрываемыеЗаказы.ОбособленныйУчетТоваровПоЗаказамПокупателей;
		НоваяСтрока.Организация             = ВыборкаЗакрываемыеЗаказы.Организация;
		НоваяСтрока.КодОперацииПартииТоваров = Перечисления.КодыОперацийПартииТоваров.СнятиеРезерваПодЗаказ;

		НоваяСтрока.ЗаказПартии = ВыборкаЗакрываемыеЗаказы.ЗаказПокупателя;
		Сч=Сч+1;
	КонецЦикла;
	
	НаборДвижений.Записать(Истина);
	
КонецПроцедуры

Процедура ДвиженияПоРегистрамУпр(РежимПроведения, ВыборкаПоШапкеДокумента, ТаблицаПоЗаказамПокупателей, ТаблицаПоРазмещению, 
								ТаблицаПоЗаказамПоставщикам, ТаблицаПоРезервам, ТаблицаПоРасчетам, Отказ, Заголовок)
								
	Если ВидОперации = Перечисления.ВидыОперацийЗакрытиеЗаказовПокупателей.ЗакрытиеЗаказов Тогда
	
		Если ТаблицаПоЗаказамПокупателей.Количество() > 0 Тогда
			
			НаборДвижений = Движения.ЗаказыПокупателей;
			
			СтруктТаблицДокумента = Новый Структура;
			СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоЗаказамПокупателей);
					
			ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
				
			ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Расход, ТаблицыДанныхДокумента, Дата);
					
		КонецЕсли;
		
		//Движения по причинам закрытия
		ТаблицаПричинЗакрытия = УправлениеЗаказами.ПодготовитьТаблицуПричинЗакрытияЗаказов(Заголовок, Ссылка, "ЗаказПокупателя","ЗакрытиеЗаказовПокупателей",ТаблицаПоЗаказамПокупателей);
		Если ТаблицаПричинЗакрытия.Количество() > 0 Тогда
			НаборДвижений   = Движения.ПричиныЗакрытияЗаказов;
			
			СтруктТаблицДокумента = Новый Структура;
			СтруктТаблицДокумента.Вставить("ТаблицаПоПричинамЗакрытия", ТаблицаПричинЗакрытия);
				
			ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
			
			ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, Неопределено, ТаблицыДанныхДокумента, Дата);
		КонецЕсли;

		Если ТаблицаПоРасчетам.Количество() > 0 Тогда
			
			НаборДвижений = Движения.РасчетыСКонтрагентами;

			СтруктТаблицДокумента = Новый Структура;
			СтруктТаблицДокумента.Вставить("ТаблицаПоРасчетам", ТаблицаПоРасчетам);
						
			ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
					
			ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Приход, ТаблицыДанныхДокумента, Дата);
			
		КонецЕсли;

	КонецЕсли;
	
	Если ТаблицаПоРазмещению.Количество() > 0 Тогда
		
		НаборДвижений = Движения.РазмещениеЗаказовПокупателей;
		
		СтруктТаблицДокумента = Новый Структура;
		СтруктТаблицДокумента.Вставить("ТаблицаПоРазмещению", ТаблицаПоРазмещению);
						
		ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
					
		ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Расход, ТаблицыДанныхДокумента, Дата);
			
	КонецЕсли;
	
	Если ТаблицаПоЗаказамПоставщикам.Количество() > 0 Тогда
		
		НаборДвижений = Движения.ЗаказыПоставщикам;
		
		СтруктТаблицДокумента = Новый Структура;
		СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоЗаказамПоставщикам);
						
		ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
					
		ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Расход, ТаблицыДанныхДокумента, Дата);
			
	КонецЕсли;
								
	Если ТаблицаПоРезервам.Количество() > 0 Тогда
		
		НаборДвижений = Движения.ТоварыВРезервеНаСкладах;
		
		СтруктТаблицДокумента = Новый Структура;
		СтруктТаблицДокумента.Вставить("ТаблицаПоТоварам", ТаблицаПоРезервам);
							
		ТаблицыДанныхДокумента = ОбщегоНазначения.ЗагрузитьТаблицыДокументаВСтруктуру(НаборДвижений, СтруктТаблицДокумента);
						
		ОбщегоНазначения.ЗаписатьТаблицыДокументаВРегистр(НаборДвижений, ВидДвиженияНакопления.Расход, ТаблицыДанныхДокумента, Дата);
			
	КонецЕсли;

КонецПроцедуры // ДвиженияПоРегистрам()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)

	Если ТипЗнч(Основание) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		// Заполнение шапки
		Ответственный = Основание.Ответственный;
		Подразделение = Основание.Подразделение;
		Организация = Основание.Организация;
		ВидОперации = Перечисления.ВидыОперацийЗакрытиеЗаказовПокупателей.ЗакрытиеЗаказов;

		// Заполнение строки
		НоваяСтрока = Заказы.Добавить();
		НоваяСтрока.ЗаказПокупателя = Основание.Ссылка;
		
	КонецЕсли;

КонецПроцедуры // ОбработкаЗаполнения()

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;

	мУдалятьДвижения = НЕ ЭтоНовый();

КонецПроцедуры // ПередЗаписью

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;

	
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ);
	КонецЕсли;

	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке      = УправлениеЗапасами.СформироватьДеревоПолейЗапросаПоШапке();
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"             , "ВалютаУправленческогоУчета", "ВалютаУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "Константы"             , "КурсВалютыУправленческогоУчета"    , "КурсВалютыУправленческогоУчета");
	УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "УчетнаяПолитика",        "ВестиПартионныйУчетПоСкладам", "ВестиПартионныйУчетПоСкладам");
    УправлениеЗапасами.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "НастройкаСпособовВеденияУправленческогоПартионногоУчета", "СпособВеденияПартионногоУчетаПоОрганизации", "СпособВеденияПартионногоУчетаПоОрганизации");
	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	СписокЗаказов = Заказы.ВыгрузитьКолонку("ЗаказПокупателя");
	
	// Подготовим таблицу товаров для проведения.
	ТаблицаПоЗаказамПокупателей = УправлениеЗаказами.ПодготовитьТаблицуДляЗакрытияЗаказовПокупателей(Ссылка, МоментВремени(),СписокЗаказов);
	
	// Подготовим таблицу тары для проведения.
	ТаблицаПоЗаказамПоставщикам = УправлениеЗаказами.ПодготовитьТаблицуДляЗакрытияЗаказовПоставщикам(Ссылка, МоментВремени(),СписокЗаказов);
	
	ТаблицаПоРазмещению = УправлениеЗаказами.ПодготовитьТаблицуДляЗакрытияРазмещения(Ссылка,МоментВремени(),СписокЗаказов,ложь,истина);
	
	ТаблицаПоРезервам = УправлениеЗаказами.ПодготовитьТаблицуДляЗакрытияРезервов(Ссылка,МоментВремени(),СписокЗаказов);
	
	ТаблицаПоРасчетам = УправлениеЗаказами.ПодготовитьТаблицуДляЗакрытияРасчетов(МоментВремени(),СписокЗаказов,-1);
	
	// Проверить заполнение ТЧ "Товары".
	ПроверитьЗаполнениеТабличнойЧастиЗаказы(ТаблицаПоЗаказамПокупателей, СтруктураШапкиДокумента, 
											Отказ, Заголовок);
	
	// Движения по документу
	Если Не Отказ Тогда

		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, 
							ТаблицаПоЗаказамПокупателей, ТаблицаПоРазмещению, ТаблицаПоЗаказамПоставщикам,
							ТаблицаПоРезервам, ТаблицаПоРасчетам, Отказ, Заголовок);

	КонецЕсли; 

КонецПроцедуры	// ОбработкаПроведения()

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка  Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");