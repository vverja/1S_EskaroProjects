
Перем КонтролироватьПорядок Экспорт;

// Процедура, обработчик события "ПередЗаписью" объекта
//
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли; 
	
	Если НЕ Отказ И ПометкаУдаления И НЕ Владелец.ПометкаУдаления Тогда
		Если Владелец.ГруппаВходящие = Ссылка Тогда
			Сообщить("Группа является группой входящих писем по умолчанию для учетной записи " + СокрЛП(Владелец) + ". Установка пометки на удаление - запрещена.");
			Отказ = Истина;
		ИначеЕсли Владелец.ГруппаИсходящие = Ссылка Тогда
			Сообщить("Группа является группой исходящих писем по умолчанию для учетной записи " + СокрЛП(Владелец) + ". Установка пометки на удаление - запрещена.");
			Отказ = Истина;
		ИначеЕсли Владелец.ГруппаУдаленные = Ссылка Тогда
			Сообщить("Группа является группой удаленных писем по умолчанию для учетной записи " + СокрЛП(Владелец) + ". Установка пометки на удаление - запрещена.");
			Отказ = Истина;
		ИначеЕсли Владелец.ГруппаЧерновики = Ссылка Тогда
			Сообщить("Группа является группой черновых писем по умолчанию для учетной записи " + СокрЛП(Владелец) + ". Установка пометки на удаление - запрещена.");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли; 
	
	Если НЕ Отказ Тогда
		ОбщегоНазначения.ПередЗаписьюОбъектаПорядка(Отказ, ЭтотОбъект, КонтролироватьПорядок);
	КонецЕсли; 
	
КонецПроцедуры


КонтролироватьПорядок = Истина;
