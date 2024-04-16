Процедура ЗаполнитьПараметры(Настройки = Неопределено, ЗаполнениеПоУмолчанию = Ложь) Экспорт
	//Сокращения
	Настройки = КомпоновщикНастроек.Настройки;
	ПараметрыДанных = КомпоновщикНастроек.Настройки.ПараметрыДанных;

	парамПериод = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Период"));
	парамПериод.Значение = Период;
	парамПериод.Использование = Истина;
		
	начПериода =  ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("начПериода"));
	начПериода.Значение = НачалоМесяца(Период);
	начПериода.Использование = Истина;
		
	конПериода =  ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("конПериода"));
	конПериода.Значение = КонецМесяца(Период);
	конПериода.Использование = Истина;

	СледующийМесяц = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("СледующийМесяц"));
	СледующийМесяц.Значение = КонецМесяца(Период) + 1;
	СледующийМесяц.Использование = Истина;
	
	
	Если Не СамостоятельнаяНастройка  ИЛИ ЗаполнениеПоУмолчанию Тогда		
		ОсновныеНачисления = ПланыВидовРасчета.ОсновныеНачисленияОрганизаций;
		ВзносыВФонды = ПланыВидовРасчета.ВзносыВФонды;
		Удержания = ПланыВидовРасчета.УдержанияОрганизаций;
		
		
		//нараховано підрядно
		списокКолонка5 = Новый СписокЗначений;
		списокКолонка5.Добавить(ОсновныеНачисления.ДоговорПодряда);
		списокКолонка5.Добавить(ОсновныеНачисления.СдельнаяОплата);
		
		//нараховано почасово
		списокКолонка6 = Новый СписокЗначений;
		списокКолонка6.Добавить(ОсновныеНачисления.ОкладПоДням);
		списокКолонка6.Добавить(ОсновныеНачисления.ТарифЧасовой);
		списокКолонка6.Добавить(ОсновныеНачисления.ОкладПоЧасам);
		списокКолонка6.Добавить(ОсновныеНачисления.ТарифДневной);
		списокКолонка6.Добавить(ОсновныеНачисления.ОплатаПоСреднему);
		
		списокКолонка7 = Новый СписокЗначений;
		списокКолонка7.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка8 = Новый СписокЗначений;
		списокКолонка8.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка9 = Новый СписокЗначений;
		списокКолонка9.Добавить(ОсновныеНачисления.Квартальная);
		списокКолонка9.Добавить(ОсновныеНачисления.Месячная);
		списокКолонка9.Добавить(ОсновныеНачисления.Годовая);

		списокКолонка10 = Новый СписокЗначений;
		списокКолонка10.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка11 = Новый СписокЗначений;
		списокКолонка11.Добавить(ОсновныеНачисления.ДоплатаЗаВечерниеЧасы);
		списокКолонка11.Добавить(ОсновныеНачисления.ДоплатаЗаНочныеЧасы);
		
		списокКолонка12 = Новый СписокЗначений;
		списокКолонка12.Добавить(ОсновныеНачисления.ДоплатаЗаПраздничныеИВыходные);
		списокКолонка12.Добавить(ОсновныеНачисления.ОплатаСверхурочных);
		
		списокКолонка13 = Новый СписокЗначений;
		списокКолонка13.Добавить(ОсновныеНачисления.Простой);
		списокКолонка13.Добавить(ОсновныеНачисления.ПростойПоСредней);
		списокКолонка13.Добавить(ОсновныеНачисления.ПочасовойПростой);
		списокКолонка13.Добавить(ОсновныеНачисления.ПочасовойПростойПоСредней);
		
		списокКолонка14 = Новый СписокЗначений;
		списокКолонка14.Добавить(ОсновныеНачисления.ОплатаПоСреднемуОтп);
		списокКолонка14.Добавить(ОсновныеНачисления.ОтпускПоБеременностиИРодам);		
		
		списокКолонка16 = Новый СписокЗначений;
		списокКолонка16.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка17 = Новый СписокЗначений;
		списокКолонка17.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка18 = Новый СписокЗначений;
		списокКолонка18.Добавить(ОсновныеНачисления.ОплатаБЛПоТравмеВБыту);
		списокКолонка18.Добавить(ОсновныеНачисления.ОплатаПоСреднемуБЛ);
		списокКолонка18.Добавить(ОсновныеНачисления.ОплатаПоСреднемуБЛОрганизации);
		
		списокКолонка20 = Новый СписокЗначений;
		списокКолонка20.Добавить(ОсновныеНачисления.ПустаяСсылка());
		
		списокКолонка22 = Новый СписокЗначений;
		списокКолонка22.Добавить(Удержания.ПустаяСсылка());
		
		списокКолонка27 = Новый СписокЗначений;
		списокКолонка27.Добавить(Удержания.АлиментыПроцентом);
		списокКолонка27.Добавить(Удержания.АлиментыПроцентомДоПредела);
		списокКолонка27.Добавить(Удержания.АлиментыФиксированнойСуммой);
		списокКолонка27.Добавить(Удержания.АлиментыФиксированнойСуммойДоПредела);
		списокКолонка27.Добавить(Удержания.ИЛПроцентом);
		списокКолонка27.Добавить(Удержания.ИЛПроцентомДоПредела);
		списокКолонка27.Добавить(Удержания.ИЛФиксированнойСуммой);
		списокКолонка27.Добавить(Удержания.ИЛФиксированнойСуммойДоПредела);

		
		
		списокСчетаЗарплата = Новый СписокЗначений;
		списокСчетаЗарплата.Добавить(ПланыСчетов.Хозрасчетный.РасчетыПоЗаработнойПлате); //661
		списокСчетаЗарплата.Добавить(ПланыСчетов.Хозрасчетный.РасчетыПоДругимВыплатам); //663
		
		списокВыплаты = Новый СписокЗначений;
		списокВыплаты.Добавить(Перечисления.КодыОперацийВзаиморасчетыСРаботникамиОрганизаций.Выплата);
		
		списокОсновнойСотрудник = Новый СписокЗначений;
		списокОсновнойСотрудник.Добавить(Перечисления.ВидыЗанятостиВОрганизации.ОсновноеМестоРаботы);
		списокОсновнойСотрудник.Добавить(Перечисления.ВидыЗанятостиВОрганизации.Совместительство);
				
		парамКолонка5 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка5")); //Нараховано підрядно
		парамКолонка5.Значение = СписокКолонка5;
		парамКолонка5.Использование = Истина;
		
		парамКолонка6 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка6")); //Нараховано почасово
		парамКолонка6.Значение = СписокКолонка6;
		парамКолонка6.Использование = Истина;
		
		парамКолонка7 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка7")); //пустая колонка
		парамКолонка7.Значение = списокКолонка7;
		парамКолонка7.Использование = Истина;
		
		парамКолонка8 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка8")); //пустая колонка
		парамКолонка8.Значение = списокКолонка8;
		парамКолонка8.Использование = Истина;
		
		парамКолонка9 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка9"));
	    парамКолонка9.Значение = списокКолонка9;
		парамКолонка9.Использование = Истина;
		
		парамКолонка10 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка10"));
		парамКолонка10.Значение = списокКолонка10;
		парамКолонка10.Использование = Истина;
		
		парамКолонка11 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка11"));
		парамКолонка11.Значение = списокКолонка11;
		парамКолонка11.Использование = Истина;
		
		парамКолонка12 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка12"));
		парамКолонка12.Значение = списокКолонка12;
		парамКолонка12.Использование = Истина;
		
		парамКолонка13 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка13"));
		парамКолонка13.Значение = списокКолонка13;
		парамКолонка13.Использование = Истина;
		
		парамКолонка14 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка14"));
		парамКолонка14.Значение = списокКолонка14;
		парамКолонка14.Использование = Истина;
		
		парамКолонка16 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка16"));
		парамКолонка16.Значение = списокКолонка16;
		парамКолонка16.Использование = Истина;
		
		парамКолонка17 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка17"));
		парамКолонка17.Значение = списокКолонка17;
		парамКолонка17.Использование = Истина;
		
		парамКолонка18 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка18"));
		парамКолонка18.Значение = списокКолонка18;
		парамКолонка18.Использование = Истина;
		
		парамКолонка20= ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка20"));
		парамКолонка20.Значение = списокКолонка20;
		парамКолонка20.Использование = Истина;
		
       	парамКолонка22 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка22"));
		парамКолонка22.Значение = списокКолонка22;
		парамКолонка22.Использование = Истина;
		
		парамКолонка27 = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка27"));
		парамКолонка27.Значение = списокКолонка27;
		парамКолонка27.Использование = Истина;
		
		парамВыплаты = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамКолонка30"));
		парамВыплаты.Значение = списокВыплаты;
		парамВыплаты.Использование = Истина;
		
		парамСчетаЗарплата = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамСчетаЗарплата"));
		парамСчетаЗарплата.Значение = списокСчетаЗарплата;
		парамСчетаЗарплата.Использование = Истина;

		парамОсновнойСотрудник = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамОсновнойСотрудник"));
		парамОсновнойСотрудник.Значение = списокОсновнойСотрудник;
		парамОсновнойСотрудник.Использование = Истина;
		
		парамВидДвиженияПриход = ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("парамВидДвиженияПриход"));
		парамВидДвиженияПриход.Значение = ВидДвиженияНакопления.Приход;
		парамвидДвиженияПриход.Использование = Истина;
		
	//
	Иначе
	
		КомпоновщикНастроек.ЗагрузитьНастройки(ЭтотОбъект.СохраненныеНастройки);
	КонецЕсли;
	
КонецПроцедуры
