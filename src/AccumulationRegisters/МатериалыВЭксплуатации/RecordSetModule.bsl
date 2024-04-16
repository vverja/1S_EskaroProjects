Перем мПериод Экспорт; 
Перем мТаблицаДвижений Экспорт;

Процедура ВыполнитьПриход() Экспорт
	
	мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "Период");
	мТаблицаДвижений.ЗаполнитьЗначения( Истина,  "Активность");
	мТаблицаДвижений.ЗаполнитьЗначения( ВидДвиженияНакопления.Приход, "ВидДвижения");

	Загрузить(мТаблицаДвижений);
	
КонецПроцедуры // ВыполнитьДвижение()

Процедура ВыполнитьРасход() Экспорт
	
	мТаблицаДвижений.ЗаполнитьЗначения( мПериод, "Период");
	мТаблицаДвижений.ЗаполнитьЗначения( Истина,  "Активность");
	мТаблицаДвижений.ЗаполнитьЗначения( ВидДвиженияНакопления.Расход, "ВидДвижения");

	Загрузить(мТаблицаДвижений);
	
КонецПроцедуры // ВыполнитьДвижение()

// Процедура контролирует остаток по данному регистру по переданному документу
// и его табличной части. В случае недостатка товаров выставляется флаг отказа и 
// выдается сообщение.
//
// Параметры:
//  ДокументОбъект    - объект проводимого документа, 
//  ИмяТабличнойЧасти - строка, имя табличной части, которая проводится по регистру, 
//  СтруктураШапкиДокумента - структура, содержащая значения "через точку" ссылочных реквизитов по шапке документа,
//  Отказ             - флаг отказа в проведении,
//  Заголовок         - строка, заголовок сообщения об ошибке проведения.
//
Процедура КонтрольОстатков(ДокументОбъект, ИмяТабличнойЧасти, СтруктураШапкиДокумента, Отказ, Заголовок, РежимПроведения) Экспорт

	Если РежимПроведения <> РежимПроведенияДокумента.Оперативный Тогда
		Возврат;
	КонецЕсли; 
	
	МетаданныеДокумента = ДокументОбъект.Метаданные();
	ИмяДокумента        = МетаданныеДокумента.Имя;
	ИмяТаблицы          = ИмяДокумента + "." + СокрЛП(ИмяТабличнойЧасти);
	
	// Текст вложенного запроса, ограничивающего номенклатуру при получении остатков
	ТекстЗапросаСписокНоменклатуры = "
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Номенклатура 
	|ИЗ
	|	Документ." + ИмяТаблицы +"
	|ГДЕ Ссылка = &ДокументСсылка";
	
	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка", СтруктураШапкиДокумента.Ссылка);
	Запрос.УстановитьПараметр("Подразделение",  СтруктураШапкиДокумента.Подразделение);
	
	Запрос.Текст = "
	|ВЫБРАТЬ // Запрос, контролирующий остатки в производстве
	|	Док.Номенклатура.Представление                         КАК НоменклатураПредставление,
	|	Док.Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаХраненияОстатковПредставление,
	|	Док.ХарактеристикаНоменклатуры				           КАК ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры				           		   КАК СерияНоменклатуры,
	|	Док.ФизЛицо					           		   		   КАК ФизЛицо,
	|	Док.СхемаНазначенияИспользования.Представление      		   КАК СхемаНазначенияИспользованияПредставление,
	|	Док.СпособОтраженияРасходов.Представление      		   КАК СпособОтраженияРасходовПредставление,
	|	Док.СрокПолезногоИспользования      		   КАК СрокПолезногоИспользования,
	|	Док.Качество.Представление      		               КАК КачествоПредставление,
	|	СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент) КАК ДокументКоличество,
	|	ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0)       КАК ОстатокКоличество
	|ИЗ 
	|	Документ." + ИмяТаблицы + " КАК Док
	|
	|	ЛЕВОЕ СОЕДИНЕНИЕ
	|		РегистрНакопления.МатериалыВЭксплуатации.Остатки(,
	|			Номенклатура В (" + ТекстЗапросаСписокНоменклатуры + ")
	|			И Подразделение = &Подразделение
	|			) КАК Остатки
	|	ПО 
	|		Док.Номенклатура                  = Остатки.Номенклатура
	| 		И Док.ХарактеристикаНоменклатуры  = Остатки.ХарактеристикаНоменклатуры
	| 		И Док.СерияНоменклатуры  		  = Остатки.СерияНоменклатуры
	| 		И Док.ФизЛицо  		  			  = Остатки.ФизЛицо
	| 		И Док.СхемаНазначенияИспользования	  = Остатки.СхемаНазначенияИспользования
	| 		И Док.СпособОтраженияРасходов	  = Остатки.СпособОтраженияРасходов
	| 		И Док.СрокПолезногоИспользования	  = Остатки.СрокПолезногоИспользования
	| 		И Док.Качество              	  = Остатки.Качество
	| 		И Док.Ссылка.Подразделение 		  = Остатки.Подразделение
	|
	|ГДЕ
	|	Док.Ссылка  =  &ДокументСсылка
	|
	|СГРУППИРОВАТЬ ПО
	|
	|	Док.Номенклатура,
	|	Док.ХарактеристикаНоменклатуры,
	|	Док.СерияНоменклатуры,
	|	Док.ФизЛицо,
	|	Док.СхемаНазначенияИспользования,
	|	Док.СпособОтраженияРасходов,
	|	Док.СрокПолезногоИспользования,
	|	Док.Качество
	|
	|ИМЕЮЩИЕ ЕСТЬNULL(МАКСИМУМ(Остатки.КоличествоОстаток), 0) < СУММА(Док.Количество * Док.Коэффициент /Док.Номенклатура.ЕдиницаХраненияОстатков.Коэффициент)
	|
	|ДЛЯ ИЗМЕНЕНИЯ РегистрНакопления.МатериалыВЭксплуатации.Остатки // Блокирующие чтение таблицы остатков регистра для разрешения коллизий многопользовательской работы
	|";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл

		СтрокаСообщения = "Остатка " + 
		УправлениеЗапасами.ПредставлениеНоменклатуры(Выборка.НоменклатураПредставление, 
								  Выборка.ХарактеристикаНоменклатуры,
								  Выборка.СерияНоменклатуры) +
		", схема назначения использования <" + Выборка.СхемаНазначенияИспользованияПредставление + ">, " +
		"способ отражения расходов <" + Выборка.СпособОтраженияРасходовПредставление + ">, " +
		"срок полезного использования <" + Выборка.СрокПолезногоИспользования + ">, " +
		"качества <" + Выборка.КачествоПредставление + ">, " +
		"у работника " + (Выборка.ФизЛицо) + " недостаточно.";

		УправлениеЗапасами.ОшибкаНетОстатка(СтрокаСообщения, Выборка.ОстатокКоличество, Выборка.ДокументКоличество,
		Выборка.ЕдиницаХраненияОстатковПредставление, Отказ, Заголовок);

	КонецЦикла;

КонецПроцедуры // КонтрольОстатков()
