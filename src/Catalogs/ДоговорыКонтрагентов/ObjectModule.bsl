////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТИРУЕМЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Функция проверяет, существуют ли ссылки на договор в движениях регистров накопления.
// Если есть - нельзя менять:
//  - Валюту взаиморасчетов
//  - Ведение взаиморасчетов.
//
// Параметры:
//  Нет.
//
// Возвращаемое значение:
//  Истина - если есть движения, Ложь - если нет.
//
Функция СуществуютСсылки() Экспорт

	Возврат ПолныеПрава.ПроверитьНаличиеСсылокНаДоговорКонтрагента(Ссылка);

КонецФункции //  СуществуютСсылки()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура вызывается перед записью элемента справочника.
//
Процедура ПередЗаписью(Отказ)

	// Проверим можно ли изменять реквизиты договора.
	// Проверка осуществляется только если записывается уже существующий договор
	Если НЕ ОбменДанными.Загрузка И НЕ ЭтоНовый() Тогда

		Если ЭтоГруппа Тогда

			// Для группы владельца менять нельзя
			Если Владелец <> Ссылка.Владелец Тогда

				Сообщить("Нельзя изменять контрагента для группы договоров.", СтатусСообщения.Важное);
				Отказ = Истина;

			КонецЕсли; 

		Иначе

			// Проверим возможность смены владельца для договора
			Если Владелец <> Ссылка.Владелец Тогда

				Запрос = Новый Запрос;
				Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
				|	ДокументыПоДоговоруКонтрагента.Ссылка
				|ИЗ
				|	КритерийОтбора.ДокументыПоДоговоруКонтрагента(&Договор) КАК ДокументыПоДоговоруКонтрагента";
				
				Запрос.УстановитьПараметр("Договор", Ссылка);
				
				Результат = Запрос.Выполнить();
				ЕстьДокументыПоДоговору = НЕ Результат.Пустой();
				
				Если ЕстьДокументыПоДоговору Тогда
					Сообщить("Существуют документы, оформленные по договору """ + Наименование + """.
							 |Контрагент договора не может быть изменен, элемент не записан.", 
							 СтатусСообщения.Важное);
					Отказ = Истина;
				КонецЕсли; 

			КонецЕсли; 

			// Проверим возможность смены способа ведения взаиморасчетов и валюты взаиморасчетов
			
			Если (ВедениеВзаиморасчетов      <> Ссылка.ВедениеВзаиморасчетов 	  И ЗначениеЗаполнено(Ссылка.ВедениеВзаиморасчетов))
			 ИЛИ (ВалютаВзаиморасчетов       <> Ссылка.ВалютаВзаиморасчетов		  И ЗначениеЗаполнено(Ссылка.ВалютаВзаиморасчетов))
			 ИЛИ (ВидДоговора                <> Ссылка.ВидДоговора 				  И ЗначениеЗаполнено(Ссылка.ВидДоговора))
			 ИЛИ (Организация                <> Ссылка.Организация 				  И ЗначениеЗаполнено(Ссылка.Организация))
			 ИЛИ (СхемаНалоговогоУчета       <> Ссылка.СхемаНалоговогоУчета 	  И ЗначениеЗаполнено(Ссылка.СхемаНалоговогоУчета))
			 ИЛИ (СхемаНалоговогоУчетаПоТаре <> Ссылка.СхемаНалоговогоУчетаПоТаре И ЗначениеЗаполнено(Ссылка.СхемаНалоговогоУчетаПоТаре))
			 ИЛИ (ВидУсловийДоговора         <> Ссылка.ВидУсловийДоговора         И ЗначениеЗаполнено(Ссылка.ВидУсловийДоговора))
			 ИЛИ (ВедениеВзаиморасчетовРегл <> Ссылка.ВедениеВзаиморасчетовРегл И ЗначениеЗаполнено(Ссылка.ВедениеВзаиморасчетовРегл))
			 ИЛИ (ВестиПоДокументамРасчетовСКонтрагентом <> Ссылка.ВестиПоДокументамРасчетовСКонтрагентом И ЗначениеЗаполнено(Ссылка.ВестиПоДокументамРасчетовСКонтрагентом)) Тогда
			
			
				Если ЭтотОбъект.СуществуютСсылки() Тогда

					Сообщить("Существуют документы, проведенные по договору """ + Наименование + """.
							 |Реквизиты ""Организация"", ""Ведение взаиморасчетов"", ""Валюта взаиморасчетов"", ""Вид договора"", 
							 |""По документам расчетов с контрагентом"", ""Схема налогового учета"" и ""Условия выполнения договора"" не могут быть изменены, элемент не записан.", 
							 СтатусСообщения.Важное);
					Отказ = Истина;

				КонецЕсли;

			КонецЕсли;
			
			Если  ОбособленныйУчетТоваровПоЗаказамПокупателей<>Ссылка.ОбособленныйУчетТоваровПоЗаказамПокупателей Тогда
				Если ПолныеПрава.ПроверитьНаличиеСсылокНаДоговорКонтрагентаВЗаказахПокупателей(Ссылка) Тогда
					Сообщить("Существуют заказы покупателей, проведенные по договору """ + Наименование + """.
					|Реквизит ""Обособленный учет товаров по заказам покупателей"" не может быть изменен, элемент не записан.", 
					СтатусСообщения.Важное);
					Отказ = Истина;

				КонецЕсли;
				
			КонецЕсли;

		КонецЕсли;

	КонецЕсли;

	// Проверим заполнение и очистим неиспользуемые реквизиты элемента договора.
	Если Не ЭтоГруппа Тогда

		// Проверим, заполнена ли валюта.
		Если НЕ ОбменДанными.Загрузка И НЕ ЗначениеЗаполнено(ВалютаВзаиморасчетов) Тогда
			Сообщить("Не указана валюта договора.", СтатусСообщения.Важное);
			Отказ = Истина;
		КонецЕсли;

		// Проверим, заполнена ли организация.
		Если НЕ ОбменДанными.Загрузка И НЕ ЗначениеЗаполнено(Организация) Тогда
			Сообщить("Не указана организация, от которой заключен договор.", СтатусСообщения.Важное);
			Отказ = Истина;
		КонецЕсли;

		// Проверим, заполнен ли способ ведения взаиморасчетов.
		Если НЕ ОбменДанными.Загрузка И НЕ ЗначениеЗаполнено(ВедениеВзаиморасчетов) Тогда
			Сообщить("Не указан способ ведения взаиморасчетов по договору (УУ)", СтатусСообщения.Важное);
			Отказ = Истина;
		КонецЕсли;

		Если НЕ ОбменДанными.Загрузка И НЕ ЗначениеЗаполнено(ВедениеВзаиморасчетовРегл) Тогда
			Сообщить("Не указан способ ведения взаиморасчетов по договору (БУ и НУ).", СтатусСообщения.Важное);
			Отказ = Истина;
		КонецЕсли;
		
		// Проверим, заполнен ли вид договора.
		Если НЕ ОбменДанными.Загрузка Тогда
		
			Если НЕ ЗначениеЗаполнено(ВидДоговора) Тогда
				Сообщить("Не указан вид договора.", СтатусСообщения.Важное);
				Отказ = Истина;
			Иначе
				// Проверим, правильно ли заполнен вид договора
				Если (ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем ИЛИ ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером)
					И НЕ Владелец.Покупатель Тогда
					Сообщить("Вид договора ""С покупателем"" может устанавливаться только когда у контрагента указано что он является покупателем.", СтатусСообщения.Важное);
					Отказ = Истина;
				ИначеЕсли (ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком ИЛИ ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомитентом)
					И НЕ Владелец.Поставщик Тогда
					Сообщить("Вид договора ""С поставщиком"" может устанавливаться только когда у контрагента указано что он является поставщиком.", СтатусСообщения.Важное);
					Отказ = Истина;
				ИначеЕсли ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.Прочее
					И ВестиПоДокументамРасчетовСКонтрагентом
					Тогда
					Сообщить("Флажок ""По документам расчетов с контрагентами"" не может устанавливаться у договоров с видом ""Прочее"".", СтатусСообщения.Важное);
					Отказ = Истина;
				КонецЕсли; 
			КонецЕсли;
		
		КонецЕсли; 

	КонецЕсли;

КонецПроцедуры // ПередЗаписью()
