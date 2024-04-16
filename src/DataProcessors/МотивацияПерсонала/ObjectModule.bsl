#Если Клиент Тогда
	
// Переменные, хранящие сведения о ПВРах
Перем мСведенияОВидахРасчета Экспорт;

Процедура ВыводПоказателя(Макет, Показатель, СтрокаЗначения, ТекущийРаздел)
	
	// Печать значения.
	Область = Макет.ПолучитьОбласть("Показатель");
	Область.Параметры.Показатель = Строка (Показатель) ;
						
	Область.Параметры.ТипПоказателя = СтрокаЗначения ;
	ТекущийРаздел.Вывести(Область);

КонецПроцедуры
	
// Печатает Схему мотивации по переданной таблице.
//
// Параметры
//  ТаблицаВидовРасчета  – Таблица значений. Колонки:
//                 ВидРасчета - сотавной тип Упр.Начисления 
//                 и Уп.Удержания плна видов расчета.
//  
Процедура ПечатьСМ(ТаблицаВидовРасчета, ВидОрганизационнойСтруктурыПредприятия) Экспорт

	Если ТаблицаВидовРасчета.Количество() < 1 Тогда 
		Возврат
	КонецЕсли;	
	
	// Заведение печатной формы
	ПечатныйДокумент = Новый ТабличныйДокумент;
	ТекущийРаздел    = Новый ТабличныйДокумент;	
	ПечатныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_СхемаМотивации";
	Макет = ПолучитьОбщийМакет("МакетСхемыМотивации");
	
	ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ПечатныйДокумент.Вывести(ОбластьЗаголовок);
	
	// Распечатка таблицы видов расчета.
	Для Каждого СтрокаВидаРасчета Из ТаблицаВидовРасчета Цикл
		
		ВидРасчета = СтрокаВидаРасчета.ВидРасчета;
		
		Если Не ЗначениеЗаполнено(ВидРасчета) Тогда
			Продолжить;
		КонецЕсли;
		
		СведенияОВидеРасчета = РаботаСДиалогами.ПолучитьСведенияОВидеРасчетаСхемыМотивации(мСведенияОВидахРасчета, ВидРасчета);
		КоличествоПоказателей = СведенияОВидеРасчета["ФактКоличествоПоказателей"];
		
		// Вывод шапки печатной формы.
		Подразделение = СтрокаВидаРасчета.Подразделение;
		Если ЗначениеЗаполнено(Подразделение) Тогда
			ОбластьПодразделение = Макет.ПолучитьОбласть("Шапка|Подразделение");
			ОбластьПодразделение.Параметры.Подразделение = Подразделение;
			ПечатныйДокумент.Вывести(ОбластьПодразделение);
		КонецЕсли;
		Должность = СтрокаВидаРасчета.Должность;
		Если ЗначениеЗаполнено(Должность) Тогда
			ОбластьДолжность = Макет.ПолучитьОбласть("Шапка|Должность");
			ОбластьДолжность.Параметры.Должность 	= Должность; 
			ПечатныйДокумент.Вывести(ОбластьДолжность);
		КонецЕсли;
		ОбластьВидСМИлиОрганизация = Макет.ПолучитьОбласть("Шапка|ВидСМИлиОрганизация");
		Если ВидОрганизационнойСтруктурыПредприятия = Перечисления.ВидыОрганизационнойСтруктурыПредприятия.ПоЦентрамОтветственности Тогда
			ВидСхемыМотивации = СтрокаВидаРасчета.ВидСхемыМотивации;
			Если ЗначениеЗаполнено(ВидСхемыМотивации) Тогда
				ОбластьВидСМИлиОрганизация.Параметры.ВидСхемыМотивации = "Вид схемы мотивации:" + Символы.Таб + ВидСхемыМотивации;
				ПечатныйДокумент.Вывести(ОбластьВидСМИлиОрганизация);
			КонецЕсли;
		Иначе
			Организация = СтрокаВидаРасчета.Организация;
			Если ЗначениеЗаполнено(Организация) Тогда
				ОбластьВидСМИлиОрганизация.Параметры.ВидСхемыМотивации = "Организация:" + Символы.Таб + СтрокаВидаРасчета.Организация;			
				ПечатныйДокумент.Вывести(ОбластьВидСМИлиОрганизация);
			КонецЕсли;
		КонецЕсли;
		
		ВидРасчетаОбъект = ВидРасчета.ПолучитьОбъект();
		
		// Вывод на печать Вида расчета.
		Область = Макет.ПолучитьОбласть("ВидРасчета");
		Область.Параметры.ВидРасчета = ВидРасчета;
		Если ВидОрганизационнойСтруктурыПредприятия = Перечисления.ВидыОрганизационнойСтруктурыПредприятия.ПоЦентрамОтветственности Тогда
			Область.Параметры.Описание = ВидРасчетаОбъект.Комментарий;
		КонецЕсли;
		ТекущийРаздел.Вывести(Область);
		
		Формула = "Размер начисления = " + ПроведениеРасчетов.ВизуализироватьФормулуРасчета(ВидРасчетаОбъект, "Текст");
		
		СпособРасчета = ВидРасчетаОбъект.СпособРасчета;
		
		Если КоличествоПоказателей > 0 Тогда
			СтрокаЗначения = "Устанавливается в размере " + Строка(СтрокаВидаРасчета.показатель1) + " и корректируется при начислении.";
		Иначе
			СтрокаЗначения = "Корректируется при начислении.";
		КонецЕсли;
		СтрокаЗначения_2 = "Значение вводится при расчете.";	
		
		Если  СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ФиксированнойСуммой Или СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоДоговоруФиксированнойСуммой
			Тогда
			
			// Формирование строки значения и вида показателя.		
			ВыводПоказателя(Макет, "Фиксированная сумма", СтрокаЗначения, ТекущийРаздел);
			
		ИначеЕсли  СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ИсполнительныйЛистФиксСуммойДоПредела Тогда
			
			// Формирование строки значения и вида показателя.			
			ВыводПоказателя(Макет, "Фиксированная сумма, до удержания указанной в документе суммы", СтрокаЗначения, ТекущийРаздел);
			
		ИначеЕсли  СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.СдельныйЗаработок Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Сдельная выработка", СтрокаЗначения, ТекущийРаздел);
			
		ИначеЕсли  СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.НулеваяСумма Тогда
			Значение   = 0;
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "0", СтрокаЗначения, ТекущийРаздел);
						
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоДневнойТарифнойСтавке Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Тарифная ставка", СтрокаЗначения, ТекущийРаздел);
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Отработанное время в днях", СтрокаЗначения_2, ТекущийРаздел);			
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоЧасовойТарифнойСтавке Тогда
			
			// Формирование строки значения и вида показателя.			
			ВыводПоказателя(Макет, "Тарифная ставка", СтрокаЗначения, ТекущийРаздел);			
			
			// Формирование строки значения и вида показателя.			
			ВыводПоказателя(Макет, "Отработанное время в часах", СтрокаЗначения_2, ТекущийРаздел);		
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.Процентом Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Тарифная ставка", СтрокаЗначения, ТекущийРаздел);
				
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Расчетная база", СтрокаЗначения_2, ТекущийРаздел);			
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПочтовыйСбор Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Процент сбора", СтрокаЗначения, ТекущийРаздел);			
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Сумма по исполнительному листу", СтрокаЗначения_2, ТекущийРаздел);
						
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ИсполнительныйЛистПроцентом 
			Или СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ИсполнительныйЛистПроцентомДоПредела Тогда
								
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Процент удержаний", СтрокаЗначения, ТекущийРаздел);						
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Расчетная база", СтрокаЗначения_2, ТекущийРаздел);			
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Исчисленный НДФЛ", СтрокаЗначения_2, ТекущийРаздел);						
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ДоплатаЗаВечерниеЧасы Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Часовая тарифная ставка", СтрокаЗначения, ТекущийРаздел);			
									
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Процент доплаты", СтрокаЗначения_2, ТекущийРаздел);						
						
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Вечернее время в часах", СтрокаЗначения_2, ТекущийРаздел);						
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ДоплатаЗаНочныеЧасы Тогда
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Часовая тарифная ставка", СтрокаЗначения, ТекущийРаздел);			
						
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Процент доплаты", СтрокаЗначения_2, ТекущийРаздел);					
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Ночное время в часах", СтрокаЗначения_2, ТекущийРаздел);			
					
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоСреднемуЗаработку Тогда
						
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Средний дневной (часовой) заработок", СтрокаЗначения, ТекущийРаздел);			
						
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Время в днях (часах)", СтрокаЗначения_2, ТекущийРаздел);						
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоСреднемуЗаработкуФСС Тогда		
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Средний дневной заработок", СтрокаЗначения, ТекущийРаздел);						
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Время в календарных днях", СтрокаЗначения_2, ТекущийРаздел);						
				
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоМесячнойТарифнойСтавкеПоДням Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Тарифная ставка (оклад)", СтрокаЗначения, ТекущийРаздел);						
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Норма времени за месяц в днях", СтрокаЗначения_2, ТекущийРаздел);						
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Отработанное время в днях", СтрокаЗначения_2, ТекущийРаздел);						
			
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ПоМесячнойТарифнойСтавкеПоЧасам Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Тарифная ставка (оклад)", СтрокаЗначения, ТекущийРаздел);						
						
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Норма времени за месяц в часах", СтрокаЗначения_2, ТекущийРаздел);						
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Отработанное время в часах", СтрокаЗначения_2, ТекущийРаздел);						
			
			
				
		ИначеЕсли СпособРасчета = Перечисления.СпособыРасчетаОплатыТруда.ДоплатаДоСреднегоЗаработка Тогда
			
			// Формирование строки значения и вида показателя.
			ВыводПоказателя(Макет, "Средний заработок", СтрокаЗначения, ТекущийРаздел);									
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "Начислено", СтрокаЗначения_2, ТекущийРаздел);									
			
			// Формирование строки значения и вида показателя.	
			ВыводПоказателя(Макет, "0", СтрокаЗначения_2, ТекущийРаздел);						
			
		Иначе
			
			// По все показателям данного вида расчета.
			Для позиция = 1 По КоличествоПоказателей Цикл
				
				Показатель = "";
				Значение   = 0;
				Валюта     = "";
				ТипПоказателя = "";
				ВозможностьИзменения = "";
				
				Показатель	= СведенияОВидеРасчета["Показатель" + позиция];
				Значение	= СтрокаВидаРасчета["Показатель"+позиция];
				Валюта		= СтрокаВидаРасчета["Валюта"+позиция];
				
				// Формулировка валюты или единиц измерения.
				ТипПоказателя = Показатель.ТипПоказателя;
				
				Если  ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.Процентный Тогда
					Валюта = "% (в процентах)";
				КонецЕсли;
				
				Если  ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.Числовой Тогда
					Валюта = "как число";
				КонецЕсли;
				
				ВозможностьИзменения = Показатель.ВозможностьИзменения;
				
				
				// Печать показателя уместна, если показатель не пустое значение.
				Если ЗначениеЗаполнено(Показатель) Тогда
					
					
					// Печать показателей.
					
					Если  ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.ОценочнаяШкалаПроцентная 
						Или  ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.ОценочнаяШкалаЧисловая тогда
						
						// Печать таблицы.
						Область = Макет.ПолучитьОбласть("ШапкаТаблицы");
						Область.Параметры.Показатель = Строка (Показатель) ;
						ТекущийРаздел.Вывести(Область);
						
						Если ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.ОценочнаяШкалаПроцентная Тогда
							Размерность = "%";
						Иначе
							Размерность = "";
						КонецЕсли;
						
						
						// Получить таблицу оценок.
						Запрос = новый Запрос;
						Запрос.Текст = "ВЫБРАТЬ
						|	СоставШкалОценкиПоказателейРасчета.ЗначениеС,
						|	СоставШкалОценкиПоказателейРасчета.ЗначениеПо,
						|	СоставШкалОценкиПоказателейРасчета.Размер
						|ИЗ
						|	РегистрСведений.СоставШкалОценкиПоказателейРасчета КАК СоставШкалОценкиПоказателейРасчета
						|
						|ГДЕ
						|	СоставШкалОценкиПоказателейРасчета.ШкалаОценкиПоказателя.Ссылка = &Показатель";
						
						Запрос.УстановитьПараметр("Показатель",Показатель);
						
						ТаблицаОценок = Запрос.Выполнить().Выгрузить();
						
						// Печать таблицы с оценками.
						Область = Макет.ПолучитьОбласть("СтрокаТаблицы");
						
						Для Каждого СтрокаОценки из ТаблицаОценок Цикл
							Область.Параметры.От        = Строка (СтрокаОценки.ЗначениеС);
							Область.Параметры.По        = Строка (СтрокаОценки.ЗначениеПо);
							Область.Параметры.Результат = Строка (СтрокаОценки.Размер) + Размерность;
							ТекущийРаздел.Вывести(Область);
						КонецЦикла;
						
						Область = Макет.ПолучитьОбласть("КонецТаблицы");
						ТекущийРаздел.Вывести(Область);
						
					Иначе
						// Печать значения.
						Область = Макет.ПолучитьОбласть("Показатель");
						Область.Параметры.Показатель = Строка (Показатель) ;
						
						// Формирование строки значения и вида показателя.
						Если ВозможностьИзменения = Перечисления.ИзменениеПоказателейСхемМотивации.НеИзменяется Тогда
							СтрокаЗначения = "Устанавливается в размере " + Строка(Значение) + " " + Строка (Валюта) + ".";	
							
						ИначеЕсли ВозможностьИзменения = Перечисления.ИзменениеПоказателейСхемМотивации.ИзменяетсяПриРасчете 
							Или ВозможностьИзменения = Перечисления.ИзменениеПоказателейСхемМотивации.ВиденНоНеРедактируетсяПриРасчете Тогда
							СтрокаЗначения = "Устанавливается в размере " + Строка(Значение) + " " + Строка (Валюта) + " и корректируется при начислении.";	
							
						ИначеЕсли ВозможностьИзменения = Перечисления.ИзменениеПоказателейСхемМотивации.ВводитсяПриРасчете Или
							НЕ ЗначениеЗаполнено(ВозможностьИзменения) Тогда
							
							Если ТипПоказателя = Перечисления.ТипыПоказателейСхемМотивации.Денежный Тогда
								СтрокаЗначения = "Значение и валюта вводятся при расчете.";					
							Иначе	
								СтрокаЗначения = "Значение вводится при расчете.";	
							КонецЕсли;
						КонецЕсли;
						
						Область.Параметры.ТипПоказателя = СтрокаЗначения ;
						ТекущийРаздел.Вывести(Область);
					КонецЕсли;
					
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
				
		// Вывод на печать конца вида расчета.
		Область = Макет.ПолучитьОбласть("КонецВидаРасчета");
		Область.Параметры.Формула = Формула; 
		ТекущийРаздел.Вывести(Область);		
		
		// вывод на печать раздела.
		ПечатныйДокумент.Вывести(ТекущийРаздел);
		ТекущийРаздел.Очистить();
		
	КонецЦикла;
	
	// Вывод печатной формы на экран.
	УниверсальныеМеханизмы.НапечататьДокумент(ПечатныйДокумент,,, "Данные по схеме мотивации.");

КонецПроцедуры // ПечатьСМ()

#КонецЕсли
