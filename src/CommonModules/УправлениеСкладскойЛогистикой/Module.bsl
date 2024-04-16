Функция ПолучитьЕдиницу(Номенклатура, ЕдиницаПоКлассификатору) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕдиницыИзмерения.Ссылка
	|ИЗ
	|	Справочник.ЕдиницыИзмерения КАК ЕдиницыИзмерения
	|ГДЕ
	|	ЕдиницыИзмерения.Владелец = &Номенклатура
	|	И ЕдиницыИзмерения.ЕдиницаПоКлассификатору = &ЕдиницаПоКлассификатору
	|	И НЕ ЕдиницыИзмерения.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("ЕдиницаПоКлассификатору", ЕдиницаПоКлассификатору);
	тзРез = Запрос.Выполнить().Выгрузить();
	
	Если тзРез.Количество() > 1 Тогда
		Сообщить("У номенклатуры """ + СокрЛП(Номенклатура.Наименование) + """ обнаружено несколько единиц <" + СокрЛП(ЕдиницаПоКлассификатору.Наименование) + ">. Для расчетов выбрана первая.");
	ИначеЕсли тзРез.Количество() = 0 Тогда
		Сообщить("У номенклатуры """ + СокрЛП(Номенклатура.Наименование) + """ не найдена единица <" + СокрЛП(ЕдиницаПоКлассификатору.Наименование) + ">.");
		Возврат Неопределено;
	КонецЕсли;	
	
	Возврат тзРез[0].Ссылка;
КонецФункции

Функция ПолучитьВидЯчейки(Ячейка, НаДату) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СостояниеВидовЯчеекСрезПоследних.ВидЯчейки
	|ИЗ
	|	РегистрСведений.СостояниеВидовЯчеек.СрезПоследних(&НаДату, Ячейка = &Ячейка) КАК СостояниеВидовЯчеекСрезПоследних";
	
	Запрос.УстановитьПараметр("НаДату", НаДату);
	Запрос.УстановитьПараметр("Ячейка", Ячейка);
	тзРез = Запрос.Выполнить().Выгрузить();
	
	Если тзРез.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;	
	
	Возврат тзРез[0].ВидЯчейки;
КонецФункции

Функция ПолучитьЗонуЯчейки(Ячейка, НаДату) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СостояниеЗонЯчеекСрезПоследних.Зона
	|ИЗ
	|	РегистрСведений.СостояниеЗонЯчеек.СрезПоследних(&НаДату, Ячейка = &Ячейка) КАК СостояниеЗонЯчеекСрезПоследних";
	
	Запрос.УстановитьПараметр("НаДату", НаДату);
	Запрос.УстановитьПараметр("Ячейка", Ячейка);
	тзРез = Запрос.Выполнить().Выгрузить();
	
	Если тзРез.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;	
	
	Возврат тзРез[0].Зона;
КонецФункции

Функция ПолучитьДокументПеремещения(ДокументОтгрузки, СообщатьОбОшибках = Истина) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПеремещениеПоСкладу.Ссылка
	|ИЗ
	|	Документ.ПеремещениеПоСкладу КАК ПеремещениеПоСкладу
	|ГДЕ
	|	ПеремещениеПоСкладу.ДокументОтгрузки = &ДокументОтгрузки
	|	И ПеремещениеПоСкладу.Проведен
	|	И ПеремещениеПоСкладу.ВидПеремещения = ЗНАЧЕНИЕ(Перечисление.ВидыСкладскихПеремещений.НаОснованииОтгрузки)";
	
	Запрос.УстановитьПараметр("ДокументОтгрузки", ДокументОтгрузки);
	тзРезультат = Запрос.Выполнить().Выгрузить();
	
	Если тзРезультат.Количество() > 1 Тогда
		Если СообщатьОбОшибках Тогда
			Сообщить("По документу отгрузки """ + ДокументОтгрузки + """ найдено несколько проведенных перемещений", СтатусСообщения.Важное);
		КонецЕсли;
		Возврат Неопределено;
	ИначеЕсли тзРезультат.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		Возврат тзРезультат[0].Ссылка;
	КонецЕсли;	
КонецФункции

Функция ПолучитьНовыйНомерПаллета(Склад) Экспорт
	нзНомераПаллет = РегистрыСведений.НомераПаллет.СоздатьНаборЗаписей();
	нзНомераПаллет.Отбор.Склад.Установить(Склад);
	нзНомераПаллет.Прочитать();
	
	Если нзНомераПаллет.Количество() = 0 Тогда
		НоваяЗапись = нзНомераПаллет.Добавить();
		НоваяЗапись.Склад = Склад;
		НоваяЗапись.ТекущийНомерПаллета = 1;
		ТекущийНомерПаллета = 1;
	Иначе
		ТекущийНомерПаллета = нзНомераПаллет[0].ТекущийНомерПаллета + 1;
		нзНомераПаллет[0].ТекущийНомерПаллета = ТекущийНомерПаллета;
	КонецЕсли;
	
	нзНомераПаллет.Записать(Истина);
	
	Возврат ТекущийНомерПаллета;
КонецФункции

Функция ПолучитьТаблицуПодчиненныхДокументов(ДокументОснование)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОтборИОтгрузкаОтгрузка.Ссылка,
	|	ОтборИОтгрузкаОтгрузка.НомерСтроки,
	|	ОтборИОтгрузкаОтгрузка.Номенклатура,
	|	ОтборИОтгрузкаОтгрузка.ЕдиницаХраненияОстатков,
	|	ОтборИОтгрузкаОтгрузка.КоличествоФактическиОтгруженное КАК Количество
	|ИЗ
	|	Документ.ОтборИОтгрузка.Отгрузка КАК ОтборИОтгрузкаОтгрузка
	|ГДЕ
	|	ОтборИОтгрузкаОтгрузка.ДокументОснование = &ДокументОснование
	|	И ОтборИОтгрузкаОтгрузка.Ссылка.Проведен
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПриемкаИРазмещениеПриемка.Ссылка,
	|	ПриемкаИРазмещениеПриемка.НомерСтроки,
	|	ПриемкаИРазмещениеПриемка.Номенклатура,
	|	ПриемкаИРазмещениеПриемка.ЕдиницаХраненияОстатков,
	|	ПриемкаИРазмещениеПриемка.КоличествоФактическиПринятое
	|ИЗ
	|	Документ.ПриемкаИРазмещение.Приемка КАК ПриемкаИРазмещениеПриемка
	|ГДЕ
	|	ПриемкаИРазмещениеПриемка.ДокументОснование = &ДокументОснование
	|	И ПриемкаИРазмещениеПриемка.Ссылка.Проведен";
	
	Запрос.УстановитьПараметр("ДокументОснование", ДокументОснование);
	Возврат Запрос.Выполнить().Выгрузить();
КонецФункции

Функция ДоступноПоРолям(ВидДоступа) Экспорт
	ДоступРазрешен = Ложь;
	Если ВидДоступа = "ИзменениеЗавершенныхДокументов" Тогда
		Если РольДоступна("КорректировкаЗавершенныхДокументовПоЛогистикеСклада")
			ИЛИ РольДоступна("АдминистраторЛогистики") Тогда
			
			ДоступРазрешен = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ДоступРазрешен;
КонецФункции


Процедура ПриОтменеПроведенияОснованийДокументовПоЛогистикеОбработкаУдаленияПроведения(Источник, Отказ) Экспорт
	Если НЕ РольДоступна("ПроведениеТиповыхДокументовБезКонтролейПоЛогистике") Тогда
		ДокументОснование = Источник.Ссылка;
		тзРез = ПолучитьТаблицуПодчиненныхДокументов(ДокументОснование);
		тзРез.Свернуть("Ссылка");
		Если тзРез.Количество() > 0 Тогда
			Отказ = Истина;
			Сообщить("В системе присутствуют документы по логистике оформленные на основании данного документа:", СтатусСообщения.Важное);
			Для каждого стрРез Из тзРез Цикл
				Сообщить("  " + СокрЛП(стрРез.Ссылка), СтатусСообщения.Информация);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПриПроведенииОснованийДокументовПоЛогистикеОбработкаПроведения(Источник, Отказ, РежимПроведения) Экспорт
	Если НЕ РольДоступна("ПроведениеТиповыхДокументовБезКонтролейПоЛогистике") Тогда
		ДокументОснование = Источник.Ссылка;
		тзРез = ПолучитьТаблицуПодчиненныхДокументов(ДокументОснование);
		тзРезКопия = тзРез.Скопировать();
		тзРез.Свернуть("Номенклатура", "Количество");
		Если тзРез.Количество() > 0 Тогда
			Если ТипЗнч(Источник) = Тип("ДокументОбъект.КомплектацияНоменклатуры") Тогда
				
			Иначе
				Для каждого стрРез Из тзРез Цикл
					ПараметрыОтбора = Новый Структура("Номенклатура", стрРез.Номенклатура);
					мсвСтрокиДок = Источник.Товары.НайтиСтроки(ПараметрыОтбора);
					КоличествоВДокументе = 0;
					Для каждого стрДок Из мсвСтрокиДок Цикл
						КоличествоВДокументе = КоличествоВДокументе + стрДок.Количество;
						Если стрДок.ЕдиницаИзмерения <> стрРез.Номенклатура.ЕдиницаХраненияОстатков Тогда
							Отказ = Истина;
							Сообщить("В строке №" + стрДок.НомерСтроки + " выбрана единица не являющаяся единицей хранения остатков номенклатуры """
									+ СокрЛП(стрРез.Номенклатура) + """", СтатусСообщения.Важное);
						КонецЕсли;
					КонецЦикла;
					Если КоличествоВДокументе < стрРез.Количество Тогда
						Отказ = Истина;
						ПараметрыОтбора = Новый Структура("Номенклатура", стрРез.Номенклатура);
						мсвСтрокиДокЛог = тзРезКопия.НайтиСтроки(ПараметрыОтбора);
						
						Для каждого стр Из мсвСтрокиДокЛог Цикл
							Сообщить("Количество номенклатуры """ + СокрЛП(стрРез.Номенклатура) + """: " + КоличествоВДокументе + 
							" меньше фактического количества в документе """ + СокрЛП(стр.Ссылка) + """: " + стрРез.Количество + "", СтатусСообщения.Важное);
						КонецЦикла;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПроверитьНаПрисутствиеВПозднихДокументах(Отказ, Граница, мсвЯчейки, мсвДокументы = Неопределено, мсвИсключаемыеДокументы = Неопределено) Экспорт
	////Временно
	//Возврат;
	Если РольДоступна("АдминистраторЛогистики") Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПриемкаИРазмещениеРазмещение.Ссылка КАК Ссылка,
	|	ПриемкаИРазмещениеРазмещение.Ссылка.МоментВремени КАК МоментВремени
	|ИЗ
	|	Документ.ПриемкаИРазмещение.Размещение КАК ПриемкаИРазмещениеРазмещение
	|ГДЕ
	|	ПриемкаИРазмещениеРазмещение.ЯчейкаФакт В(&СписокЯчеек)
	|	И ПриемкаИРазмещениеРазмещение.Ссылка.МоментВремени > &МоментВремени
	|	И НЕ ПриемкаИРазмещениеРазмещение.Ссылка В (&СписокДокументов)
	|	И ПриемкаИРазмещениеРазмещение.Ссылка.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	ПриемкаИРазмещениеРазмещение.Ссылка,
	|	ПриемкаИРазмещениеРазмещение.Ссылка.МоментВремени
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ОтборИОтгрузкаОтбор.Ссылка,
	|	ОтборИОтгрузкаОтбор.Ссылка.МоментВремени
	|ИЗ
	|	Документ.ОтборИОтгрузка.Отбор КАК ОтборИОтгрузкаОтбор
	|ГДЕ
	|	ОтборИОтгрузкаОтбор.ЯчейкаФакт В(&СписокЯчеек)
	|	И ОтборИОтгрузкаОтбор.Ссылка.МоментВремени > &МоментВремени
	|	И НЕ ОтборИОтгрузкаОтбор.Ссылка В (&СписокДокументов)
	|	И ОтборИОтгрузкаОтбор.Ссылка.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	ОтборИОтгрузкаОтбор.Ссылка,
	|	ОтборИОтгрузкаОтбор.Ссылка.МоментВремени
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ОтборИОтгрузкаПерекомплектация.Ссылка,
	|	ОтборИОтгрузкаПерекомплектация.Ссылка.МоментВремени
	|ИЗ
	|	Документ.ОтборИОтгрузка.Перекомплектация КАК ОтборИОтгрузкаПерекомплектация
	|ГДЕ
	|	ОтборИОтгрузкаПерекомплектация.Ссылка.МоментВремени > &МоментВремени
	|	И ОтборИОтгрузкаПерекомплектация.Ячейка В(&СписокЯчеек)
	|	И НЕ ОтборИОтгрузкаПерекомплектация.Ссылка В (&СписокДокументов)
	|	И ОтборИОтгрузкаПерекомплектация.Ссылка.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	ОтборИОтгрузкаПерекомплектация.Ссылка,
	|	ОтборИОтгрузкаПерекомплектация.Ссылка.МоментВремени
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ПеремещениеПоСкладуПеремещение.Ссылка,
	|	ПеремещениеПоСкладуПеремещение.Ссылка.МоментВремени
	|ИЗ
	|	Документ.ПеремещениеПоСкладу.Перемещение КАК ПеремещениеПоСкладуПеремещение
	|ГДЕ
	|	ПеремещениеПоСкладуПеремещение.Ссылка.МоментВремени > &МоментВремени
	|	И (ПеремещениеПоСкладуПеремещение.ЯчейкаФактОткуда В (&СписокЯчеек)
	|			ИЛИ ПеремещениеПоСкладуПеремещение.ЯчейкаФактКуда В (&СписокЯчеек))
	|	И НЕ ПеремещениеПоСкладуПеремещение.Ссылка В (&СписокДокументов)
	|	И ПеремещениеПоСкладуПеремещение.Ссылка.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	ПеремещениеПоСкладуПеремещение.Ссылка,
	|	ПеремещениеПоСкладуПеремещение.Ссылка.МоментВремени
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ИнвентаризацияТовары.Ссылка,
	|	ИнвентаризацияТовары.Ссылка.МоментВремени
	|ИЗ
	|	Документ.Инвентаризация.Товары КАК ИнвентаризацияТовары
	|ГДЕ
	|	ИнвентаризацияТовары.Ссылка.МоментВремени > &МоментВремени
	|	И ИнвентаризацияТовары.ФактическаяЯчейка В(&СписокЯчеек)
	|	И НЕ ИнвентаризацияТовары.Ссылка В (&СписокДокументов)
	|	И ИнвентаризацияТовары.Ссылка.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	ИнвентаризацияТовары.Ссылка,
	|	ИнвентаризацияТовары.Ссылка.МоментВремени
	|
	|УПОРЯДОЧИТЬ ПО
	|	МоментВремени,
	|	Ссылка";
	
	Запрос.УстановитьПараметр("СписокЯчеек", мсвЯчейки);
	Запрос.УстановитьПараметр("МоментВремени", Граница.Значение);
	Запрос.УстановитьПараметр("СписокДокументов", мсвИсключаемыеДокументы);
	тзРезультат = Запрос.Выполнить().Выгрузить();
	
	Если тзРезультат.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	мсвДокументы = тзРезультат.ВыгрузитьКолонку("Ссылка");
КонецПроцедуры

//Верескул И.О. Последнее изменение 18.12.2013
Процедура ВыгрузкаВ_EXCEL_ДляИЛС(ТабЗначений, НазваниеДокумента, Док, Склад) Экспорт
    //ИЗМЕНЕНО Верескул Игорь(Начало 15.11.2018
    //Если НазваниеДокумента = "ПередачаХранения" Тогда
    //    НоваяВыгрузкаВ_EXCEL(Док.Ссылка, "НаПрием", Склад);	
    //Иначе
    //    НоваяВыгрузкаВ_EXCEL(Док.Ссылка,, Склад);	
    //КонецЕсли; 
    //
    //Окончание)Верескул Игорь 
    СтрСклады=Новый Структура;
    СтрСклады.Вставить("СкладОтветХранение", Склад);
    СтрПолСклады=РегистрыСведений.ОтветХранение.Получить(СтрСклады);
    Если СтрПолСклады.КаталогФТП="" Тогда
    	Сообщение = Новый СообщениеПользователю;
        Сообщение.Текст = "По данному складу (" + Склад + ") нет ответ-хранения. Выгрузка невозможна";
        Сообщение.Сообщить(); 
        Возврат;
    КонецЕсли; 
    ТипДокумента= Док.Метаданные().Имя; 
    
    Номер=Док.Номер;
    ДатаДок= Формат(Док.Дата, "ДФ=ddMMyyyy");
    Попытка 
    	Эксель= Новый COMОбъект("Excel.Application");
    Исключение
    	Сообщить(ОписаниеОшибки()); 
    	Возврат;
    КонецПопытки;
    Книга = Эксель.WorkBooks.Add();
    	
    Лист = Книга.WorkSheets(1);
    Лист.Cells(1, 1).Value = ТипДокумента;
    Лист.Cells(2, 1).NumberFormat = "@";
    Лист.Cells(2, 1).Value 	= Номер;
    Лист.Cells(3, 1).Value 	= СтрПолСклады.КаталогФТП;
    //вносим дату	
    Лист.Cells(4, 1).Value =ДатаДок; 
    НомерСтроки = 5;
    Лист.Columns(2).ColumnWidth =50;
    Для Каждого Строка ИЗ ТабЗначений Цикл
    	Если ТипДокумента="ЗаказПокупателя" Тогда 
    		Если Не Строка.Размещение = Неопределено Тогда
    			Лист.Cells(НомерСтроки, 1).Value = Число(Строка.Номенклатура.Код);
    			Лист.Cells(НомерСтроки, 2).Value = Строка.Номенклатура.Наименование;
    			Лист.Cells(НомерСтроки, 3).Value = Строка.Количество;
    			Лист.Cells(НомерСтроки, 4).Value = Строка.ЕдиницаИзмерения.Наименование;
    			НомерСтроки = НомерСтроки + 1;
    		КонецЕсли;
    	Иначе 
    		Лист.Cells(НомерСтроки, 1).Value = Число(Строка.Номенклатура.Код);
    		Лист.Cells(НомерСтроки, 2).Value = Строка.Номенклатура.Наименование;
    		Лист.Cells(НомерСтроки, 3).Value = Строка.Количество;
    		Лист.Cells(НомерСтроки, 4).Value = Строка.ЕдиницаИзмерения.Наименование;
    		НомерСтроки = НомерСтроки + 1;
    	КонецЕсли
    КонецЦикла;
    Если НомерСтроки=5 Тогда 
    	Сообщить ("Нет товаров на складе!!! Выгрузка отменена");
    	Эксель.DisplayAlerts=0;
    	Эксель.Application.Quit();
    	Возврат;
    КонецЕсли;
    ИмяФайла=СокрЛП(НазваниеДокумента)
    			+"_"+Лев(ТипДокумента,1)+Номер+"_"+ДатаДок+"_"+СтрПолСклады.КаталогФТП+".xls";
    					
    ПутьСохраненияФайла=Строка(Константы.ПутьВыгрузкиДляИЛС.Получить())
    					+"\eskaro4ils\"+СтрПолСклады.КаталогФТП+"\"+ИмяФайла;   
    Попытка
    	Книга.SaveAs(ПутьСохраненияФайла);             
    Исключение
    	Сообщить(ОписаниеОшибки());
    	Эксель.Application.Quit();
    	Возврат;	
    КонецПопытки;
    Эксель.Application.Quit();
    Сообщить("Файл успешно выгружен в "+ПутьСохраненияФайла);
	////FTP
	//Попытка
	//	СтрокаПодключения=Константы.FTPСерверИЛС.Получить();
	//	Сервер=СтрПолучитьСтроку(СтрокаПодключения,1);
	//	Порт=СтрПолучитьСтроку(СтрокаПодключения,2);
	//	Логин=СтрПолучитьСтроку(СтрокаПодключения,3);
	//	Пароль=СтрПолучитьСтроку(СтрокаПодключения,4);
	//	
	//	КаталогВыгрузки=СтрПолучитьСтроку(СтрокаПодключения,5)+"/"+СтрПолСклады.КаталогФТП;
	//	
	//	Соединение=Новый FTPСоединение(Сервер,Порт,Логин,Пароль,,Истина,);
	//	Соединение.УстановитьТекущийКаталог(КаталогВыгрузки);
	//	Соединение.Записать(ПутьСохраненияФайла,ИмяФайла);
	//Исключение
	//	Сообщить(ОписаниеОшибки());
	//	Возврат;
	//КонецПопытки;
	//Сообщить("Файл успешно выгружен в "+"ftp://77.222.128.234"+Соединение.ТекущийКаталог()+"/"+ИмяФайла);
	    
КонецПроцедуры

//ИЗМЕНЕНО Верескул Игорь(Начало 13.11.2018
Процедура НоваяВыгрузкаВ_EXCEL(Ссылка, ТипДокумента="НаВыдачу", Склад)Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
    |	ОтветХранение.КаталогФТП
    |ИЗ
    |	РегистрСведений.ОтветХранение КАК ОтветХранение
    |ГДЕ
    |	ОтветХранение.СкладОтветХранение = &СкладОтветХранение";
    Запрос.УстановитьПараметр("СкладОтветХранение", Склад);
    РезультатЗапроса = Запрос.Выполнить().Выбрать();
    Если НЕ РезультатЗапроса.Следующий() Тогда
    	Сообщить("Склад " + Склад + " не является складом ответ-хранения");
        Возврат;
    КонецЕсли;  
    ПовторнаяВыгрузка = Ложь;    
    Запрос.Текст = "ВЫБРАТЬ
                   |    ВыгрузкаЗаявокНаОХ.Номер,
                   |    ВыгрузкаЗаявокНаОХ.ДатаСоздания,
                   |    ВыгрузкаЗаявокНаОХ.ИмяФайла
                   |ИЗ
                   |    РегистрСведений.ВыгрузкаЗаявокНаОХ КАК ВыгрузкаЗаявокНаОХ
                   |ГДЕ
                   |    ВыгрузкаЗаявокНаОХ.Документ = &Документ";
    Запрос.УстановитьПараметр("Документ", Ссылка);
    РезультатЗапроса = Запрос.Выполнить().Выбрать();
    Если РезультатЗапроса.Следующий() Тогда
		//Ответ = Вопрос("Данный документ уже выгружался. Выгрузить повторно?", РежимДиалогаВопрос.ДаНет, 60);
		//Если Ответ = КодВозвратаДиалога.Нет Тогда
		//	возврат;
		//Иначе
            ПовторнаяВыгрузка = Истина;
		//КонецЕсли;  
    КонецЕсли; 
    
    ДатаДок=Формат(Ссылка.Дата, "ДФ=ddMMyyyy");
    ИмяФайла=СокрЛП(ТипДокумента) +"_"+Лев(Ссылка.Метаданные().Имя,1)+Ссылка.Номер+"_"+ДатаДок+".xls";

    ПутьСохраненияФайла=Строка(Константы.ПутьВыгрузкиДляИЛС.Получить())
						+"\in\"+ИмяФайла; 

    МаксимальныйНомер = 0;
    МЗ = РегистрыСведений.ВыгрузкаЗаявокНаОХ.СоздатьМенеджерЗаписи();
    МЗ.Документ = Ссылка;
    МЗ.ДатаСоздания = ТекущаяДата();
    МЗ.Ответственный = ПараметрыСеанса.ТекущийПользователь;
    МЗ.ИмяФайла = ИмяФайла;
    Если НЕ ПовторнаяВыгрузка Тогда
        Запрос = Новый Запрос;
        Запрос.Текст = "ВЫБРАТЬ
        |	МАКСИМУМ(ВыгрузкаЗаявокНаОХ.Номер) КАК МаксимальныйНомер
        |ИЗ
        |	РегистрСведений.ВыгрузкаЗаявокНаОХ КАК ВыгрузкаЗаявокНаОХ";
        РезультатЗапроса = Запрос.Выполнить().Выбрать();
        Если РезультатЗапроса .Следующий() Тогда
            Если НЕ ЗначениеЗаполнено(РезультатЗапроса.МаксимальныйНомер) Тогда
                МаксимальныйНомер = 0;    	
            Иначе    
                МаксимальныйНомер = РезультатЗапроса.МаксимальныйНомер;
            КонецЕсли;         	
        Иначе
            МаксимальныйНомер = 0;
        КонецЕсли;
        МаксимальныйНомер = МаксимальныйНомер+1;
        МЗ.Номер = МаксимальныйНомер;
        МЗ.Записать(Ложь);
    Иначе                  
        МаксимальныйНомер = РезультатЗапроса.Номер;
        МЗ.Номер = МаксимальныйНомер;
        МЗ.Записать(ИСТИНА);
        Реквизит = Ссылка.Метаданные().Реквизиты.Найти("НомерЗаявкиОХ");
        Если Реквизит <> Неопределено Тогда
            Объект = Ссылка.Получитьобъект();
            Объект.Записать(РежимЗаписиДокумента.Запись);
        КонецЕсли; 
    КонецЕсли; 
 
	ТД = Новый ТабличныйДокумент;
    Если ТипДокумента = "НаВыдачу" Тогда
        Макет = ПолучитьОбщийМакет("ЗаявкаНаВыдачуГруза");
    Иначе	
        Макет = ПолучитьОбщийМакет("ЗявкаНаПриемГруза");
    КонецЕсли; 
    Шапка = Макет.ПолучитьОбласть("Шапка");
    ЗаполнитьЗначенияСвойств(шапка.Параметры, ссылка);   
    шапка.Параметры.Номер = МаксимальныйНомер;
    Если ТипЗнч(Ссылка)= Тип("ДокументСсылка.РезервированиеТоваров") Тогда
       	шапка.Параметры.Контрагент = Ссылка.Заказ.Контрагент;
        //ИЗМЕНЕНО Верескул Игорь(Начало 07.02.2019        
        шапка.Параметры.ДатаОтгрузки =  Ссылка.Заказ.ДатаОтгрузки;
        шапка.Параметры.кпкТорговаяТочка = Ссылка.Заказ.кпкТорговаяТочка; 
    ИначеЕсли ТипЗнч(Ссылка)= Тип("ДокументСсылка.ПеремещениеТоваров") И ТипДокумента = "НаВыдачу" Тогда 
        шапка.Параметры.Контрагент = Ссылка.Организация;
        шапка.Параметры.ДатаОтгрузки =  Ссылка.Дата;
        шапка.Параметры.кпкТорговаяТочка = Ссылка.СкладПолучатель;
        //Окончание)Верескул Игорь
    КонецЕсли; 
    ТД.Вывести(шапка);
    
    ОблСтроки = Макет.ПолучитьОбласть("Строка");
    ТЗ_Штрихкод = НайтиТоварПоШтрихкоду(Ссылка.Товары.ВыгрузитьКолонку("Номенклатура"));
    Для каждого строка Из Ссылка.Товары Цикл
        ЗаполнитьЗначенияСвойств(ОблСтроки.Параметры, строка);
        СтрокаПоискаШтрихкода = ТЗ_Штрихкод.Найти(Строка.Номенклатура, "Номенклатура");
        Если НЕ ЗначениеЗаполнено(СтрокаПоискаШтрихкода.Штрихкод) Тогда
            Сообщить("Нет штрихкода у товара " + Строка.Номенклатура);
        КонецЕсли;
        //Штрихкод = СтрокаПоискаШтрихкода.Штрихкод;
        //Артикул = Прав(СтрокаПоискаШтрихкода.Артикул,5);
        //ОблСтроки.Параметры.Штрихкод = Штрихкод;
        ЗаполнитьЗначенияСвойств(ОблСтроки.Параметры, СтрокаПоискаШтрихкода);
        ОблСтроки.Параметры.Артикул = Прав(СтрокаПоискаШтрихкода.Артикул,5);        
        Если ЗначениеЗаполнено(СтрокаПоискаШтрихкода.КолВКоробке) Тогда
            ОблСтроки.Параметры.КолКор = Окр(строка.Количество/СтрокаПоискаШтрихкода.КолВКоробке,2);	
        КонецЕсли; 
        ТД.Вывести(ОблСтроки);
    КонецЦикла;
    Попытка
        Файл = Новый Файл(ПутьСохраненияФайла);
        Если Файл.Существует() Тогда
        	УдалитьФайлы(ПутьСохраненияФайла); 
        КонецЕсли; 
        ТД.Записать(ПутьСохраненияФайла,ТипФайлаТабличногоДокумента.XLS);   	
    Исключение
        Сообщить(ОписаниеОшибки());
        Сообщить("Файл заявки не выгружен!");
        Возврат;
    КонецПопытки;
    Сообщить("Файл успешно выгружен в "+ПутьСохраненияФайла);     
КонецПроцедуры
 
//Окончание)Верескул Игорь 
Функция ПроверкаДоступностиИЛС(Склад) Экспорт
	
	Если Склад=Неопределено или Склад.Пустая() Тогда Возврат Ложь;
	КонецЕсли;
	СтрСклады=Новый Структура;
	СтрСклады.Вставить("СкладОтветХранение", Склад);
	СтрПолСклады=РегистрыСведений.ОтветХранение.Получить(СтрСклады);
	//КаталогСклада=Лев(Склад.Наименование,Найти(Склад.Наименование," ")-1);
	Если СтрПолСклады.КаталогФТП="" Тогда 
		Возврат Ложь;	
	КонецЕсли;
	Возврат Истина;
КонецФункции

Процедура НоваяПроверка(Ссылка,ТипДокумента="НаВыдачу") Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
    |    ВыгрузкаЗаявокНаОХ.Документ,
    |    ВыгрузкаЗаявокНаОХ.Номер,
    |    ВыгрузкаЗаявокНаОХ.ДатаСоздания,
    |    ВыгрузкаЗаявокНаОХ.Ответственный,
    |    ВыгрузкаЗаявокНаОХ.ИмяФайла,
    |    ВыгрузкаЗаявокНаОХ.Выполнен
    |ИЗ
    |    РегистрСведений.ВыгрузкаЗаявокНаОХ КАК ВыгрузкаЗаявокНаОХ
    |ГДЕ
    |    ВыгрузкаЗаявокНаОХ.Документ = &Документ";
    Запрос.УстановитьПараметр("Документ", Ссылка);
    ВыборкаВыгруженныхЗаявок = Запрос.Выполнить().Выбрать();
    Если НЕ ВыборкаВыгруженныхЗаявок.Следующий() Тогда
        Сообщить("Документ не выгружался!!! Выгрузите его!");
        Возврат;
    КонецЕсли;
	//Если ВыборкаВыгруженныхЗаявок.Выполнен Тогда
	//	Ответ = Вопрос("Данный документ уже проверялся, проверить повторно?", РежимДиалогаВопрос.ДаНет, 60);
	//    Если Ответ = КодВозвратаДиалога.Нет Тогда
	//    	Возврат;
	//    КонецЕсли;  
	//КонецЕсли; 
    ТД = Новый ТабличныйДокумент;
    Выполнен = Истина;
    СписокФайлов = НайтиФайлы(Строка(Константы.ПутьВыгрузкиДляИЛС.Получить()+"\out"),"*.*"); 
    Для каждого Файл Из СписокФайлов Цикл
        Попытка
            ТД.Прочитать(Файл.ПолноеИмя);	
        Исключение
            Сообщить("Ошибка чтения файла " + Файл.ПолноеИмя);
            продолжить;
        КонецПопытки; 
        Если ТипДокумента = "НаПрием" Тогда
            НомерЗаявки = СокрЛП(ТД.ПолучитьОбласть("R6C1").ТекущаяОбласть.Текст);
            ДатаЗаявки = СокрЛП(ТД.ПолучитьОбласть("R6C2").ТекущаяОбласть.Текст);
            НачальнаяСтрокаТоваров = 9;
        Иначе
            НомерЗаявки = СокрЛП(ТД.ПолучитьОбласть("R5C1").ТекущаяОбласть.Текст);
            ДатаЗаявки = СокрЛП(ТД.ПолучитьОбласть("R5C2").ТекущаяОбласть.Текст);
            НачальнаяСтрокаТоваров = 8;
        КонецЕсли;  
        Если НЕ Строка(ВыборкаВыгруженныхЗаявок.Номер) = СокрЛП(НомерЗаявки) Тогда
        	Продолжить;
        КонецЕсли; 
        ТЗ_ТоварыНаПроверку = Новый ТаблицаЗначений;
        ТЗ_ТоварыНаПроверку.Колонки.Добавить("Штрихкод");
        ТЗ_ТоварыНаПроверку.Колонки.Добавить("Артикул");
        ТЗ_ТоварыНаПроверку.Колонки.Добавить("Количество");
        Для ии =  НачальнаяСтрокаТоваров По ТД.ВысотаТаблицы Цикл            
            Штрихкод = СокрЛП(ТД.ПолучитьОбласть("R" + ии+"C3").ТекущаяОбласть.Текст);
            Артикул = СокрЛП(ТД.ПолучитьОбласть("R" + ии+"C2").ТекущаяОбласть.Текст);
            Артикул = Прав("00000000000" + Артикул,11);
            Количество = ТД.ПолучитьОбласть("R" + ии + "C4").ТекущаяОбласть.Текст;
            Если Не ЗначениеЗаполнено(Артикул) Тогда
            	Продолжить;
            КонецЕсли; 
            Если Не ЗначениеЗаполнено(Количество) Тогда
                Количество = 0;	
            КонецЕсли; 
            НоваяСтрока = ТЗ_ТоварыНаПроверку.Добавить();	
            НоваяСтрока.Штрихкод = Штрихкод;
            НоваяСтрока.Артикул = Артикул;
            НоваяСтрока.Количество = Число(Количество);
        КонецЦикла; 
        ТЗ_ТоварыНаПроверку.Свернуть("Штрихкод, Артикул", "Количество");
        СписокНоменклатуры = НайтиТоварПоШтрихкоду(Ссылка.Товары.ВыгрузитьКолонку("Номенклатура")); 
        ТЗ_Товары = Ссылка.Товары.Выгрузить(,"Номенклатура, Количество");
        ТЗ_Товары.Свернуть("Номенклатура", "Количество"); 
        Для каждого Строка Из ТЗ_Товары Цикл
        	СтрокаПоискаШтрихкода = СписокНоменклатуры.Найти(Строка.Номенклатура, "Номенклатура");
            Отбор = Новый Структура;
            Отбор.Вставить("Артикул", СтрокаПоискаШтрихкода.Артикул);
            //Отбор.Вставить("Штрихкод", СтрокаПоискаШтрихкода.Штрихкод);
            СписокНаПроверку = ТЗ_ТоварыНаПроверку.НайтиСтроки(Отбор);
            Если СписокНаПроверку.Количество() = 0 Тогда
                МЗ = РегистрыСведений.РегистрацияОшибокЗаявокНаОХ.СоздатьМенеджерЗаписи();
                МЗ.Документ = Ссылка;
                МЗ.НомерЗаявки = НомерЗаявки;
                //МЗ.НомерСтроки = Строка.НомерСтроки;
                МЗ.Номенклатура = Строка.Номенклатура;
                МЗ.Расхождение = "Товар " + Строка.Номенклатура + " не найден";
                МЗ.Записать(Истина);
                Сообщить("Товар " + Строка.Номенклатура + " не найден");
                Выполнен = Ложь;
            	Продолжить;
            КонецЕсли;
            Если СписокНаПроверку [0] .Количество <> Строка.Количество Тогда
                МЗ = РегистрыСведений.РегистрацияОшибокЗаявокНаОХ.СоздатьМенеджерЗаписи();
                МЗ.Документ = Ссылка;
                МЗ.НомерЗаявки = НомерЗаявки;
//                МЗ.НомерСтроки = Строка.НомерСтроки;
                МЗ.Номенклатура = Строка.Номенклатура;
                МЗ.Расхождение = "Расхождение количества " + Строка.Номенклатура + ",  документе " + Строка.Количество + ", в выполненной заявке " + СписокНаПроверку[0].Количество;
                МЗ.Записать(Истина);
                Сообщить("У товара " + Строка.Номенклатура + " неверное количество");	
                Сообщить("В документе " + Строка.Количество + ", в выполненной заявке " + СписокНаПроверку[0].Количество);	
                Выполнен = Ложь;
                Продолжить;
            КонецЕсли; 
        КонецЦикла;	 
        МЗ = РегистрыСведений.ВыгрузкаЗаявокНаОХ.СоздатьМенеджерЗаписи();
        ЗаполнитьЗначенияСвойств(МЗ,ВыборкаВыгруженныхЗаявок);
        МЗ.Выполнен = Выполнен;
        МЗ.Записать(Истина);
        Сообщить("Документ содержит ошибки: " + (НЕ Выполнен));
        Если Выполнен Тогда
             МЗ = РегистрыСведений.РегистрацияОшибокЗаявокНаОХ.СоздатьМенеджерЗаписи();
             МЗ.Документ = Ссылка;
             МЗ.НомерЗаявки = НомерЗаявки;
             МЗ.Прочитать();
             МЗ.Удалить();
             //МЗ.Записать(Истина);
        КонецЕсли; 
    КонецЦикла; 
КонецПроцедуры
 

Процедура ПроверкаВ_ИЛС(Док, Номер="", ТабЗначений, Склад) Экспорт
// TODO: 1. Проверка на наличие заказа в каталоге заказов по имени файла.
// 		 2. При наличии заказа - проверяем его содержимое.
// 		 3. Если есть расхождения - выводим сообщение в сервисном окне.
    Перем ИмяФайла;
    СтрСклады=Новый Структура;
    СтрСклады.Вставить("СкладОтветХранение", Склад);
    СтрПолСклады=РегистрыСведений.ОтветХранение.Получить(СтрСклады);
    
    ТЗЭксель = Новый ТаблицаЗначений;	
    
    
    Если ТипЗнч(Номер) <> Тип("ТаблицаЗначений") Тогда
        Если Номер="" Тогда
    	    Номер=Док.Номер;
    	КонецЕсли; 
    	ДатаДок=Формат(Док.Дата, "ДФ=ddMMyyyy");	
    	МаскаФайла="*"+Номер+"_"+ДатаДок+"*.xls*";
    	ФайлЗаказа=НайтиФайлы(Строка(Константы.ПутьВыгрузкиДляИЛС.Получить())+"/ils4eskaro/"+СтрПолСклады.КаталогФТП,МаскаФайла);
    	// ФайлЗаказа=Соединение.НайтиФайлы("*.xls*");
    	Если ФайлЗаказа.Количество()=0 Тогда
    		Сообщить("Не найдено подтверждение заказа! Попробуйте позже");
    		Возврат;
    	Иначе
    		ТЗЭксель = ПолучитьИзЭксельТЗ(ФайлЗаказа);
    		Если ТЗЭксель = Неопределено Тогда
    			Возврат;
    		КонецЕсли; 
    	КонецЕсли;
    иначе
    	Для каждого Строка Из Номер Цикл	
    		МаскаФайла="*"+Строка.Номер+"_"+Строка.ДатаДок+"*.xls*";
    		ФайлЗаказа=НайтиФайлы(Строка(Константы.ПутьВыгрузкиДляИЛС.Получить())+"/ils4eskaro/"+СтрПолСклады.КаталогФТП,МаскаФайла);
    		// ФайлЗаказа=Соединение.НайтиФайлы("*.xls*");
    		Если ФайлЗаказа.Количество()=0 Тогда
    			Сообщить("Не найдено подтверждение резервирования! Попробуйте позже");
    			Возврат;
    		Иначе
    			ТЗВрем = ПолучитьИзЭксельТЗ(ФайлЗаказа);
    			Если ТЗВрем = Неопределено Тогда
    				Возврат;
    			КонецЕсли; 
    			Если ТЗЭксель.Колонки.Количество() = 0 Тогда
    				ТЗЭксель = ТЗВрем.Скопировать();
    			Иначе
    				Для каждого ТЗВремСтрока Из ТЗВрем Цикл
    					НоваяСтрока = ТЗЭксель.Добавить();	
    					ЗаполнитьЗначенияСвойств(НоваяСтрока, ТЗВремСтрока); 
    				КонецЦикла; 
    			КонецЕсли; 			
    		КонецЕсли;
    	КонецЦикла; 		
    КонецЕсли;
    
    	ТЗЭксель.Свернуть("Кол001", "Кол003");
    	ТабЗначений.Свернуть("Номенклатура","Количество");
    	Если ТЗЭксель.Количество()<= ТабЗначений.Количество() Тогда 
    		Ошибки=0;
    		СтруктураПоиска = Новый Структура; 
    		Для Каждого Строка ИЗ ТабЗначений Цикл
    			СтруктураПоиска.Вставить("Кол001", Число(Строка.Номенклатура.Код));
    			НайденнаяСтрока=ТЗЭксель.НайтиСтроки(СтруктураПоиска);
    			Если НайденнаяСтрока.Количество()=0 Тогда 
    				Сообщить ("Не найден товар "+Строка.Номенклатура.Наименование+ ". Код " +  Строка.Номенклатура.Код);
    				Ошибки=Ошибки+1;
    			ИначеЕсли НайденнаяСтрока[0].Кол003 <> Строка.Количество Тогда
    				Сообщить ("Не совпадает количество у товара "+Строка.Номенклатура.Наименование);
    				Сообщить ("У нас "+Строка.Количество+" - у них "+НайденнаяСтрока[0].Количество);
    				Ошибки=Ошибки+1;
    			КонецЕсли;
    		КонецЦикла;
    	Иначе
    		Ошибки=0;
    		СтруктураПоиска = Новый Структура; 
    		Для Каждого Строка ИЗ ТЗЭксель Цикл
    			Если Строка.Кол001=Неопределено Тогда 
    				Продолжить;
    			КонецЕсли;
    			НайденаяНоменклатура=Справочники.Номенклатура.НайтиПоКоду(Прав("00000000000"+Формат(Строка.Кол001,"ЧГ=0"),11));
    			СтруктураПоиска.Вставить("Номенклатура",НайденаяНоменклатура);
    			НайденнаяСтрока=ТабЗначений.НайтиСтроки(СтруктураПоиска);
    			Если НайденнаяСтрока.Количество()=0 Тогда 
    				Сообщить ("У нас не найден товар "+НайденаяНоменклатура + ". Код " +  НайденаяНоменклатура.Код);
    				Ошибки=Ошибки+1;
    			ИначеЕсли НайденнаяСтрока[0].Количество <> Строка.Кол003 Тогда
    				Сообщить ("Не совпадает количество у товара "+НайденаяНоменклатура);
    				Сообщить ("У них "+Строка.Кол003+" - у нас "+НайденнаяСтрока[0].Количество);
    				Ошибки=Ошибки+1;
    			КонецЕсли;
    			
    		КонецЦикла;
    		
    	КонецЕсли;
    	ВремяНачала = ТекущаяДата();
    	ТребуемаяПаузаВСекундах = 3;
    	ПрошлоВремени = 0;
    	Пока ПрошлоВремени < ТребуемаяПаузаВСекундах Цикл
    		ПрошлоВремени = ТекущаяДата() - ВремяНачала;
    	КонецЦикла;
    //Попытка 
    //	УдалитьФайлы(ИмяФайла);
    //Исключение 
    //	Сообщить(ОписаниеОшибки());
    //КонецПопытки;
    Сообщить("Документ проверен! Ошибок "+Ошибки);
КонецПроцедуры

Функция ПолучитьИзЭксельТЗ(ФайлЗаказа)
	ИмяФайла=ФайлЗаказа.Получить(0);
	//	Соединение.Получить(ИмяФайлаFTP.ПолноеИмя,Константы.ПутьВыгрузкиДляИЛС.Получить()+"\"+ИмяФайлаFTP.Имя);
	//	ИмяФайла=Константы.ПутьВыгрузкиДляИЛС.Получить()+"\"+ИмяФайлаFTP.Имя;
	
	Попытка 
		Эксель= Новый COMОбъект("Excel.Application");
		Книга=Эксель.Workbooks; 
		Сообщить("Открываем файл "+ИмяФайла.ПолноеИмя+" ....");
		//Сообщить("Открываем файл "+ИмяФайлаFTP.ПолноеИмя+" ....");
		Лист=Книга.Open(ИмяФайла.ПолноеИмя).Sheets(1);
	Исключение
		Сообщить(ОписаниеОшибки()); 
		Возврат Неопределено;
	КонецПопытки;
	ТЗЭксель = Новый ТаблицаЗначений;
	Для ии = 1 По Лист.Cells.SpecialCells(11).Column Цикл       
		Попытка
			Если ии < 10 Тогда
				ТЗЭксель.Колонки.Добавить("Кол00"+Строка(ии), ,Лист.Cells(1,ии).Value);
			Иначе
				ТЗЭксель.Колонки.Добавить("Кол0"+Строка(ии), ,Лист.Cells(1,ии).Value);
			КонецЕсли;
		Исключение
			Сообщить("Не удалось добавить колонку");
		КонецПопытки; 
	КонецЦикла;
	
	КолКолонок = ии - 1;
	
	КоличествоСтрок = Лист.Cells.SpecialCells(11).Row;
	
	НомерНачальнойСтроки = 1;
	
	//Для ии = 2 По КоличествоСтрок  Цикл     
	Для ии = НомерНачальнойСтроки По КоличествоСтрок  Цикл
		стр = ТЗЭксель.Добавить();
		Для кол = 1 По КолКолонок Цикл
			стр[кол-1] = Лист.Cells(ии,кол).Value;
		КонецЦикла;
	КонецЦикла; 
	
	Эксель.Application.Quit();
	Возврат ТЗЭксель;
КонецФункции
Функция НайтиТоварПоШтрихкоду(СписокНоменклатуры)
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    Номенклатура.Ссылка КАК Номенклатура,
                   |    Номенклатура.Код КАК Артикул,
                   |    Штрихкоды.Штрихкод,
                   |    ЕСТЬNULL(Коробки.СодержитЕХО, 0) КАК КолВКоробке,
                   |    ЕСТЬNULL(Паллеты.СодержитЕХО, 0) КАК КолВПаллете
                   |ИЗ
                   |    Справочник.Номенклатура КАК Номенклатура
                   |        ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.Штрихкоды КАК Штрихкоды
                   |        ПО (Штрихкоды.Владелец = Номенклатура.Ссылка)
                   |        ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
                   |            ЕдиницыИзмерения.Владелец КАК Владелец,
                   |            ЕдиницыИзмерения.СодержитЕХО КАК СодержитЕХО
                   |        ИЗ
                   |            Справочник.ЕдиницыИзмерения КАК ЕдиницыИзмерения
                   |        ГДЕ
                   |            ЕдиницыИзмерения.ЕдиницаПоКлассификатору.Код = ""931"") КАК Коробки
                   |        ПО Номенклатура.Ссылка = Коробки.Владелец
                   |        ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
                   |            ЕдиницыИзмерения.Владелец КАК Владелец,
                   |            ЕдиницыИзмерения.СодержитЕХО КАК СодержитЕХО
                   |        ИЗ
                   |            Справочник.ЕдиницыИзмерения КАК ЕдиницыИзмерения
                   |        ГДЕ
                   |            ЕдиницыИзмерения.ЕдиницаПоКлассификатору.Код = ""930"") КАК Паллеты
                   |        ПО Номенклатура.Ссылка = Паллеты.Владелец
                   |ГДЕ
                   |    Номенклатура.Ссылка В(&СписокНоменклатуры)";
    Запрос.УстановитьПараметр("СписокНоменклатуры", СписокНоменклатуры);
    Возврат Запрос.Выполнить().Выгрузить();       	
КонецФункции
 

//Верескул И.О.