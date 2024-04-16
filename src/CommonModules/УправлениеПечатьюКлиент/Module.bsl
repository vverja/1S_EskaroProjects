
// Выполнить команду печати, которая открывает результат в форме печати документов
Процедура ВыполнитьКомандуПечати(ИмяМенеджераПечати, ИменаМакетов, ПараметрКоманды, ВладелецФормы, ПараметрыПечати) Экспорт
	
	// Проверим количество объектов
	Если НЕ ПроверитьКоличествоПереданныхОбъектов(ПараметрКоманды) Тогда
		Возврат;
	КонецЕсли;
	
	// Получим ключ уникальности открываемой формы
	КлючУникальности = Строка(Новый УникальныйИдентификатор);
	
	// Подготовим параметры для открываемой формы
	СписокПараметров = Новый СписокЗначений;
	СписокПараметров.Добавить(ИмяМенеджераПечати, "ИмяМенеджераПечати");
	СписокПараметров.Добавить(ИменаМакетов,       "ИменаМакетов");
	СписокПараметров.Добавить(ПараметрКоманды,    "ПараметрКоманды");
	СписокПараметров.Добавить(ПараметрыПечати,    "ПараметрыПечати");
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("СписокПараметров", СписокПараметров);
	
	// Откроем форму печати документов
	ОткрытьФорму("ОбщаяФорма.ПечатьДокументовУправляемая", ПараметрыОткрытия, ВладелецФормы, КлючУникальности);
	
КонецПроцедуры

// Выполнить команду печати, которая результат выводит на принтер
Процедура ВыполнитьКомандуПечатиНаПринтер(ИмяМенеджераПечати, ИменаМакетов, ПараметрКоманды, ПараметрыПечати) Экспорт

	Перем ТабличныеДокументы, ОбъектыПечати, ПараметрыВывода, Адрес, ОбъектыПечатиСоотв;
	
	// Проверим количество объектов
	Если НЕ ПроверитьКоличествоПереданныхОбъектов(ПараметрКоманды) Тогда
		Возврат;
	КонецЕсли;
	
	// Сформируем табличные документы
	ПараметрыВывода = Неопределено;
#Если ТолстыйКлиентОбычноеПриложение Тогда
	УправлениеПечатью.СформироватьПечатныеФормыДляБыстройПечатиОбычноеПриложение(
			ИмяМенеджераПечати, ИменаМакетов, ПараметрКоманды, ПараметрыПечати,
			Адрес, ОбъектыПечатиСоотв, ПараметрыВывода);
	ОбъектыПечати = Новый СписокЗначений;
	ТабличныеДокументы = ПолучитьИзВременногоХранилища(Адрес);
	Для Каждого ОбъектПечати Из ОбъектыПечатиСоотв Цикл
		ОбъектыПечати.Добавить(ОбъектПечати.Значение, ОбъектПечати.Ключ);
	КонецЦикла;
#Иначе
	УправлениеПечатью.СформироватьПечатныеФормыДляБыстройПечати(
			ИмяМенеджераПечати, ИменаМакетов, ПараметрКоманды, ПараметрыПечати,
			ТабличныеДокументы, ОбъектыПечати, ПараметрыВывода);
#КонецЕсли

	// Распечатаем
	РаспечататьТабличныеДокументы(ТабличныеДокументы, ПараметрыВывода.ДоступнаПечатьПоКомплектно, ОбъектыПечати);
	
КонецПроцедуры

// Вывести табличные документы на принтер
Процедура РаспечататьТабличныеДокументы(ТабличныеДокументы, Знач ДоступнаПечатьПоКомплектно, ОбъектыПечати) Экспорт

	#Если ВебКлиент Тогда
		ДоступнаПечатьПоКомплектно = Ложь;
	#КонецЕсли
	
	Колво = ТабличныеДокументы.Количество();
	Если Не ДоступнаПечатьПоКомплектно Тогда
		Для Каждого Элемент Из ТабличныеДокументы Цикл
			ТабДок = Элемент.Значение;
			ТабДок.Напечатать(Истина);
		КонецЦикла;
		Возврат;
	КонецЕсли;

	

	Для Каждого Элемент Из ОбъектыПечати Цикл
		
		ИмяОбласти = Элемент.Представление;
		Для Каждого Элемент Из ТабличныеДокументы Цикл
			ТабДок = Элемент.Значение;
			Область = ТабДок.Области.Найти(ИмяОбласти);
			Если Область = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			ТабДок.ОбластьПечати = Область;
			ТабДок.Напечатать(Истина);
		КонецЦикла;
		
	КонецЦикла;

КонецПроцедуры

// Перед выполнение команды печати проверить, был ли передан хотя бы один объект, так как
// для команд с множественным режимом использования может быть передан пустой массив.
Функция ПроверитьКоличествоПереданныхОбъектов(ПараметрКоманды)
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") И ПараметрКоманды.Количество() = 0 Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции
