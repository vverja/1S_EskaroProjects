
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	ПараметрыФормы = Новый Структура;
	
	ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийЗаявкиНаРасходование.ВозвратДенежныхСредствПокупателю");
	ПараметрыФормы.Вставить("ВидОперации", ВидОперации);
		
	ОткрытьФорму("Документ.ЗаявкаНаРасходованиеСредств.Форма.РасчетыСКонтрагентами", ПараметрыФормы);
	
КонецПроцедуры
