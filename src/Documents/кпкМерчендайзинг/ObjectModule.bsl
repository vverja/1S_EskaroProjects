
// Переменные модуля  
Перем мВалютаРегламентированногоУчета Экспорт;  // Валюта регламентированного учета

//// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Процедура при изменении поля ввода номенклатуры в строке табличной части "Товары".
//
Процедура ПриИзмененииНоменклатурыТоваров(СтрокаТабличнойЧасти) Экспорт

	СуммаСтроки = СтрокаТабличнойЧасти.Цена * СтрокаТабличнойЧасти.Количество;

	// Выполнить общие действия для всех документов при изменении номенклатуры.
	ОбработкаТабличныхЧастей.ПриИзмененииНоменклатурыТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект);

	// Заполняем реквизиты табличной части.
	ОбработкаТабличныхЧастей.ЗаполнитьСтавкуНДСТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект, "Реализация");
	ОбработкаТабличныхЧастей.ЗаполнитьЕдиницуЦенуПродажиТабЧасти(СтрокаТабличнойЧасти, ЭтотОбъект, мВалютаРегламентированногоУчета);
 
КонецПроцедуры // ПриИзмененииНоменклатурыТоваров()

Процедура Печать() Экспорт
	//{{_КОНСТРУКТОР_ПЕЧАТИ_ЭЛЕМЕНТ(Печать)
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	ТабДок = Новый ТабличныйДокумент;
	Макет = Документы.кпкМерчендайзинг.ПолучитьМакет("Печать");
	// Заголовок
	Область = Макет.ПолучитьОбласть("Заголовок");
	ТабДок.Вывести(Область);
	// Шапка
	Шапка = Макет.ПолучитьОбласть("Шапка");
	Шапка.Параметры.Заполнить(ЭтотОбъект);
	ТабДок.Вывести(Шапка);
	// Номенклатура
	Область = Макет.ПолучитьОбласть("НоменклатураШапка");
	ТабДок.Вывести(Область);
	ОбластьНоменклатура = Макет.ПолучитьОбласть("Номенклатура");
	Для Каждого ТекСтрокаНоменклатура Из Номенклатура Цикл
		ОбластьНоменклатура.Параметры.Заполнить(ТекСтрокаНоменклатура);
		ТабДок.Вывести(ОбластьНоменклатура);
	КонецЦикла;

	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.Защита = Ложь;
	ТабДок.ТолькоПросмотр = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	ТабДок.Показать();
	//}}_КОНСТРУКТОР_ПЕЧАТИ_ЭЛЕМЕНТ
КонецПроцедуры

мВалютаРегламентированногоУчета = глЗначениеПеременной("ВалютаРегламентированногоУчета");
