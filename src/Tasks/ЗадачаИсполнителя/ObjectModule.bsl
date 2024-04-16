////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// По описателям состояния задачи (реквизитам адресации) формирует текст инфо-строки и важность сообщения
//
// Параметры
//	Исполнитель, Роль, Организация, Выполнена - реквизиты, влияющие на состояние задачи
//
// Возвращаемое значение:
//	Структура из двух строковых значений - ТекстСообщения и ВажностьСообщения
//
Функция ПолучитьОписаниеОбъекта(Исполнитель, Роль, Организация, Выполнена) Экспорт
	
	Если Выполнена Тогда
		ТекстСообщения		= "Задача выполнена";
	Иначе
		Если ЗначениеЗаполнено(Исполнитель) Тогда
			ТекстСообщения		= "Задачу может выполнить только " + Исполнитель;
		Иначе
			ОписаниеРоли = "";
			Если ЗначениеЗаполнено(Роль) Тогда
				ОписаниеРоли = НРег(Строка(Роль));
			Иначе
				ОписаниеРоли = "кадровик или расчетчик";
			КонецЕсли;
			
			ОписаниеОрганизации = "";
			Если ЗначениеЗаполнено(Организация) Тогда
				ОписаниеОрганизации = " " + ОбщегоНазначения.ПреобразоватьСтрокуИнтерфейса("организации") + " " + Строка(Организация);
			КонецЕсли;
			
			ТекстСообщения		= "Задачу может выполнить любой " + ОписаниеРоли + ОписаниеОрганизации;
			
			РеквизитыАдресации = Новый Структура;
			Для Каждого Реквизит Из Метаданные().РеквизитыАдресации Цикл
				РеквизитыАдресации.Вставить(Реквизит.Имя, ЭтотОбъект[Реквизит.Имя]);
			КонецЦикла;
			
		КонецЕсли;
	КонецЕсли;
	
	ВажностьСообщения	= "";
	
	Возврат Новый Структура("ТекстСообщения,ВажностьСообщения", ТекстСообщения, ВажностьСообщения)

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередВыполнением()
	
	// Исполнитель берется из параметра сеанса
	Если Исполнитель.Пустая() Тогда
		Исполнитель = глЗначениеПеременной("глТекущийПользователь");
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
