
Перем мЭтоНовыйЭлемент;
Перем мМонопольныйРежимПередЗаписью;

Процедура ПриЗаписи(Отказ)
	
	СтрокаСообщенияПользователю = СообщитьИнформациюПользователюПослеСозданияНовогоУзла();
	
	#Если Клиент Тогда
	Сообщить(СтрокаСообщенияПользователю);
	#КонецЕсли
	
КонецПроцедуры

Функция СообщитьИнформациюПользователюПослеСозданияНовогоУзла() Экспорт
	
	НужноПерезапуститьВсеПодключенияКИБ = Ложь;
	
	Если мЭтоНовыйЭлемент 
		И НЕ мМонопольныйРежимПередЗаписью Тогда
		
		НужноПерезапуститьВсеПодключенияКИБ = Истина;
		
	КонецЕсли;	
	
	Если НужноПерезапуститьВсеПодключенияКИБ Тогда
		
		Если мМонопольныйРежимПередЗаписью Тогда
			
			ПолныеПрава.ОпределитьФактИспользованияРИБ();
			Возврат "";
			
		Иначе	
			
			Возврат "Для корректной работы механизма обмена данными необходимо завершить работу всех пользователей и перезапустить текущий сеанс работы 1С:Предприятия.";	
			
		КонецЕсли;
		
	Иначе
		
		Если мЭтоНовыйЭлемент Тогда
			
			ПолныеПрава.ОпределитьФактИспользованияРИБ();	
			
		КонецЕсли;
		
		Возврат "";
		
	КонецЕсли;
	
КонецФункции

Процедура ПередЗаписью(Отказ)
	
	мЭтоНовыйЭлемент = ЭтоНовый();
	
	мМонопольныйРежимПередЗаписью = ОбщегоНазначения.ОпределитьТекущийРежимРаботыМонопольный();
	
КонецПроцедуры
