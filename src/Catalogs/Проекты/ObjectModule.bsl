Перем ПрошлыйИзмененныйРодительОбъектаДоступа;

Процедура ПередЗаписью(Отказ)
	
	Если НЕ ОбменДанными.Загрузка Тогда
		
		ПрошлыйИзмененныйРодительОбъектаДоступа = ?(Не ЭтоНовый() и Не Ссылка.Родитель = Родитель, Ссылка.Родитель, Неопределено);
		НастройкаПравДоступа.ПередЗаписьюНовогоОбъектаСПравамиДоступаПользователей(ЭтотОбъект, Отказ, Родитель);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если НЕ ОбменДанными.Загрузка Тогда
		НастройкаПравДоступа.ОбновитьПраваДоступаКИерархическимОбъектамПриНеобходимости(Ссылка,ПрошлыйИзмененныйРодительОбъектаДоступа, Отказ);
	КонецЕсли;
	
КонецПроцедуры

