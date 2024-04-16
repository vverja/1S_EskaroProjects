Процедура ПроверитьПроводку(Проводка)

	СчетДт = Проводка.СчетДт;
	СчетКт = Проводка.СчетКт;
	
	// Проверим и почистим небалансовые реквизиты
	Если НЕ СчетДт.Количественный И Проводка.КоличествоДт <> 0 Тогда
	    Проводка.КоличествоДт = Неопределено;
	КонецЕсли; 

	Если НЕ СчетДт.Валютный И Проводка.ВалютаДт <> Неопределено Тогда
	    Проводка.ВалютаДт = Неопределено;
	КонецЕсли; 

	Если НЕ СчетДт.Валютный И Проводка.ВалютнаяСуммаДт <> 0 Тогда
	    Проводка.ВалютнаяСуммаДт = Неопределено;
	КонецЕсли; 

	Если НЕ СчетКт.Количественный И Проводка.КоличествоКт <> 0 Тогда
	    Проводка.КоличествоКт = Неопределено;
	КонецЕсли; 

	Если НЕ СчетКт.Валютный И Проводка.ВалютаКт <> Неопределено Тогда
	    Проводка.ВалютаКт = Неопределено;
	КонецЕсли; 

	Если НЕ СчетКт.Валютный И Проводка.ВалютнаяСуммаКт <> 0 Тогда
	    Проводка.ВалютнаяСуммаКт = Неопределено;
	КонецЕсли; 

	// Проверим сочетание баланса и забаланса
	Если СчетДт.Забалансовый И НЕ СчетКт.Забалансовый Тогда
		Проводка.СчетКт                     = Неопределено;
		Проводка.ВалютаКт                   = Неопределено;
		Проводка.КоличествоКт               = 0;
		Проводка.ВалютнаяСуммаКт            = 0;
		Для К = 1 По Проводка.СчетКт.ВидыСубконто.Количество() Цикл
			Проводка.СубконтоКт[К-1]        = Неопределено;
		КонецЦикла;
	КонецЕсли; 

	Если СчетКт.Забалансовый И НЕ СчетДт.Забалансовый Тогда
		Проводка.СчетДт                     = Неопределено;
		Проводка.ВалютаДт                   = Неопределено;
		Проводка.КоличествоДт               = 0;
		Проводка.ВалютнаяСуммаДт            = 0;
		Для К = 1 По Проводка.СчетДт.ВидыСубконто.Количество() Цикл
			Проводка.СубконтоДт[К-1]        = Неопределено;
		КонецЦикла;
	КонецЕсли; 

КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ
// 

// Обработчик события "ПередЗаписью".
// Проверяет возможность изменения записей регистра.
// Замещает пустые значения субконто составного типа значением Неопределено.
// Замещает субконто не составного типа со значением Неопределено пустым значением своего типа.
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда 
		Возврат; 
	КонецЕсли;
	
	
	Для Каждого Проводка Из ЭтотОбъект Цикл
		
		// Приведение пустых значений субконто составного типа.
		// Приведение субконто не составного типа со значением Неопределено в пустое значение своего типа
		Для Каждого Субконто Из Проводка.СубконтоДт Цикл
			ТипыСубконто = Субконто.Ключ.ТипЗначения.Типы();
			Если ТипыСубконто.Количество() > 1
			   И НЕ ЗначениеЗаполнено(Субконто.Значение) 
			   И НЕ (Субконто.Значение = Неопределено) Тогда
				Проводка.СубконтоДт.Вставить(Субконто.Ключ, Неопределено);
			ИначеЕсли ТипыСубконто.Количество() = 1	И Субконто.Значение = Неопределено Тогда
				Проводка.СубконтоДт.Вставить(Субконто.Ключ, ОбщегоНазначения.ПустоеЗначениеТипа(ТипыСубконто[0]));
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого Субконто Из Проводка.СубконтоКт Цикл
			ТипыСубконто = Субконто.Ключ.ТипЗначения.Типы();
			Если ТипыСубконто.Количество() > 1
			   И НЕ ЗначениеЗаполнено(Субконто.Значение) 
			   И НЕ (Субконто.Значение = Неопределено) Тогда
				Проводка.СубконтоКт.Вставить(Субконто.Ключ, Неопределено);
			ИначеЕсли ТипыСубконто.Количество() = 1	И Субконто.Значение = Неопределено Тогда	
				Проводка.СубконтоКт.Вставить(Субконто.Ключ, ОбщегоНазначения.ПустоеЗначениеТипа(ТипыСубконто[0]));
			КонецЕсли;
		КонецЦикла;
		
		ПроверитьПроводку(Проводка);
		
	КонецЦикла;
КонецПроцедуры