
Процедура ВыполнитьОбменДаннымиДляНастройкиОбмена(КодНастройки) Экспорт
	
	Если НЕ ЗначениеЗаполнено(КодНастройки) Тогда
		Возврат;
	КонецЕсли;
	
	НастройкаОбмена = Справочники.НастройкиОбменаДанными.НайтиПоКоду(КодНастройки);
	
	Если НЕ ЗначениеЗаполнено(НастройкаОбмена)
		ИЛИ НастройкаОбмена.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	ПроцедурыОбменаДанными.ВыполнитьОбменДаннымиПоПроизвольнойНастройке(НастройкаОбмена, Ложь);
			
КонецПроцедуры

Процедура ВыполнитьОтложенныеДвиженияДляНастройкиОбмена(КодНастройки) Экспорт
	
	Если НЕ ЗначениеЗаполнено(КодНастройки) Тогда
		Возврат;
	КонецЕсли;
	
	НастройкаОбмена = Справочники.НастройкиОбменаДанными.НайтиПоКоду(КодНастройки);
	
	Если НЕ ЗначениеЗаполнено(НастройкаОбмена)
		ИЛИ НастройкаОбмена.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;	
	
	ПроцедурыОбменаДанными.ВыполнитьОтложенныеДвиженияПоНастройкеОбмена(НастройкаОбмена);
			
КонецПроцедуры

Процедура ОбновлениеИндексаПолнотекстовогоПоиска() Экспорт
	
	Если ПолнотекстовыйПоиск.ПолучитьРежимПолнотекстовогоПоиска() = РежимПолнотекстовогоПоиска.Разрешить Тогда
		
		Если НЕ ПолнотекстовыйПоиск.ИндексАктуален() Тогда
			Попытка	
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
				УровеньЖурналаРегистрации.Информация, , ,
				"Начато регламентное индексирование порции");
				
				ПолнотекстовыйПоиск.ОбновитьИндекс(Ложь, Истина);
				
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
				УровеньЖурналаРегистрации.Информация, , ,
				"Закончено регламентное  индексирование порции");
			Исключение
				ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
				УровеньЖурналаРегистрации.Ошибка, , ,
				"Во время регламентного обновления индекса произошла неизвестная ошибка: " + ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

Процедура СлияниеИндексаПолнотекстовогоПоиска() Экспорт
	
	Если ПолнотекстовыйПоиск.ПолучитьРежимПолнотекстовогоПоиска() = РежимПолнотекстовогоПоиска.Разрешить Тогда
		
		Попытка	
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
			УровеньЖурналаРегистрации.Информация, , ,
			"Начато регламентное слияние индексов");
				
			ПолнотекстовыйПоиск.ОбновитьИндекс(Истина);
				
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
			УровеньЖурналаРегистрации.Информация, , ,
			"Закончено регламентное слияние индексов");
		Исключение
			ЗаписьЖурналаРегистрации("Полнотекстовое индексирование", 
			УровеньЖурналаРегистрации.Ошибка, , ,
			"Во время регламентного слияния индекса произошла неизвестная ошибка: " + ОписаниеОшибки());
		КонецПопытки;
		
	КонецЕсли;

КонецПроцедуры

Процедура ПересчетИтоговРегистров() Экспорт
		
	НаДату = НачалоМесяца(ТекущаяДата())-1;	
	ПересчетРегистров(РегистрыНакопления, НаДату, Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Остатки);
	ПересчетРегистров(РегистрыБухгалтерии, НаДату);	

КонецПроцедуры

Процедура ПересчетРегистров(МенеджерРегистров, НаДату, ОграничениеПоВидуРегистра = Неопределено)
	
	Для Каждого МенеджерРегистра ИЗ МенеджерРегистров Цикл
		МетаданныеРегистра = Метаданные.НайтиПоТипу(ТипЗнч(МенеджерРегистра));
		
		Если ОграничениеПоВидуРегистра <> Неопределено И МетаданныеРегистра.ВидРегистра <> ОграничениеПоВидуРегистра Тогда
			Продолжить;
		КонецЕсли;
		ПересчитатьРегистрПоДате(МенеджерРегистра, НаДату);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПересчитатьРегистрПоДате(МенеджерРегистра, НаДату)
	
	Если МенеджерРегистра.ПолучитьПериодРассчитанныхИтогов()<НаДату Тогда
		МенеджерРегистра.УстановитьПериодРассчитанныхИтогов(НаДату);
	Иначе
		МенеджерРегистра.ПересчитатьИтоги();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПолучениеЭлектронныхСообщений() Экспорт
	
	Если НЕ Константы.ИспользованиеВстроенногоПочтовогоКлиента.Получить() Тогда
		Возврат;
	КонецЕсли;
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	УчетныеЗаписиЭлектроннойПочты.Ссылка
	|ИЗ
	|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
	|ГДЕ
	|	УчетныеЗаписиЭлектроннойПочты.АвтоПолучениеОтправкаСообщений";
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.Прямой);
	УчетныеЗаписиДляПроверки = Новый Массив;
	Пока Выборка.Следующий() Цикл
		УчетныеЗаписиДляПроверки.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	ТекстОшибок = "";
	УправлениеЭлектроннойПочтой.ПолучениеОтправкаПисем(Неопределено, Справочники.Пользователи.ПустаяСсылка(),УчетныеЗаписиДляПроверки,,, Истина, Ложь, ТекстОшибок);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗаписьЖурналаРегистрации("Получение электронных сообщений", 
			УровеньЖурналаРегистрации.Информация, Метаданные.Документы.ЭлектронноеПисьмо, ,
			"Получение электронных сообщений выполнено успешно");
	Иначе
		ЗаписьЖурналаРегистрации("Получение электронных сообщений", 
			УровеньЖурналаРегистрации.Ошибка, Метаданные.Документы.ЭлектронноеПисьмо, ,
			"Получение электронных сообщений выполнено с ошибками:" + Символы.ПС + ТекстОшибок);
	КонецЕсли; 
	
КонецПроцедуры

Процедура ВыполнитьОбменДаннымиДляНастройкиАвтоматическогоОбменаДанными(КодНастройки) Экспорт
	
	Если НЕ ЗначениеЗаполнено(КодНастройки) Тогда
		Возврат;
	КонецЕсли;
	
	НастройкаОбмена = Справочники.НастройкиВыполненияОбмена.НайтиПоКоду(КодНастройки);
	
	Если НЕ ЗначениеЗаполнено(НастройкаОбмена)
		ИЛИ НастройкаОбмена.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	ПроцедурыОбменаДанными.ВыполнитьОбменПоНастройкеАвтоматическогоВыполненияОбменаДанными(НастройкаОбмена, Ложь);
	
КонецПроцедуры

Процедура РасчетСебестоимости(Настройка) Экспорт
	// Убедимся, что ссылка соответствует существующему объекту
	Попытка
		ОбъектНастройки = Настройка.ПолучитьОбъект();
	Исключение
		ВызватьИсключение "Ошибка при получении настройки, связанной с регламентным заданием: " + ОписаниеОшибки();
	КонецПопытки;
	
	// Проверим, что по настройке включено автоматическое формирование
	Если НЕ Настройка.ФормироватьДокументыАвтоматически Тогда
		ОбщегоНазначения.Сообщение("Для настройки, связанной с регламентным заданием, автоматическое формирование документов отключено");
		Возврат;
	КонецЕсли;
	
	// Заблокируем объект настройки
	ОбъектНастройки.Заблокировать();
	
	СтруктураПараметров = Новый Структура("Организация, ВидОтраженияВУчете, Задержка");
	ЗаполнитьЗначенияСвойств(СтруктураПараметров, ОбъектНастройки);
	
	СтруктураПараметров.Вставить("ВыполняемыеДействия", ОбъектНастройки.ВыполняемыеДействия.Выгрузить());
	
	УправлениеЗапасамиРасширеннаяАналитика.РасчитатьСебестоимость(СтруктураПараметров);
	
	ОбъектНастройки.Разблокировать();
	
КонецПроцедуры

Процедура РасчетЦеныНоменклатурыРеглЗадание(Настройка) Экспорт
	РасчетЦеныНоменклатуры(Настройка, Ложь);
КонецПроцедуры	

Процедура РасчетЦеныНоменклатуры(Настройка, ВызываетсяИзФормыНастройки = Ложь) Экспорт
		// Убедимся, что ссылка соответствует существующему объекту
	Попытка
		ОбъектНастройки = Настройка.ПолучитьОбъект();
	Исключение
		ВызватьИсключение "Ошибка при получении настройки, связанной с регламентным заданием: " + ОписаниеОшибки();
	КонецПопытки;
	
	// Проверим, что по настройке включено автоматическое формирование
	Если (НЕ ВызываетсяИзФормыНастройки)
	  И (НЕ Настройка.ФормироватьДокументыАвтоматически) Тогда
		ОбщегоНазначения.Сообщение("Для настройки, связанной с регламентным заданием, автоматическое формирование документов отключено");
		Возврат;
	КонецЕсли;
	
	// Заблокируем объект настройки
	Если НЕ ВызываетсяИзФормыНастройки Тогда
		ОбъектНастройки.Заблокировать();
	КонецЕсли;	
	
	СтруктураПараметров = Новый Структура("ТипЦен, СоздаватьНовыйДокумент, ВидОтраженияВУчете, ПорядокФормированияЦены, НастройкаРасчетаСебестоимости");
	ЗаполнитьЗначенияСвойств(СтруктураПараметров, ОбъектНастройки);
	
	Если СтруктураПараметров.ВидОтраженияВУчете = Перечисления.ВидыОтраженияВУчете.ОтражатьВУправленческомУчете Тогда
		СхемаКомпоновкиДанных = ОбъектНастройки.ПолучитьМакет("НастройкаРасчетаУпрУчет"); 
	Иначе
		СхемаКомпоновкиДанных = ОбъектНастройки.ПолучитьМакет("НастройкаРасчетаРеглУчет"); 
	КонецЕсли;	
	
	НастройкиКомпоновщика = ОбъектНастройки.НастройкиКомпоновщика.Получить();
	
	КомпоновщикМакетаКомпоновкиДанных = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакетаКомпоновкиДанных.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновщика);
		   
	Запрос = Новый Запрос(МакетКомпоновкиДанных.НаборыДанных.РасчетЦеныНоменклатуры.Запрос);
		   
	ОписаниеПараметровЗапроса = Запрос.НайтиПараметры();
		   
	Для каждого ОписаниеПараметраЗапроса из ОписаниеПараметровЗапроса Цикл
				   
		   Запрос.УстановитьПараметр(ОписаниеПараметраЗапроса.Имя, МакетКомпоновкиДанных.ЗначенияПараметров[ОписаниеПараметраЗапроса.Имя].Значение);
		   
	КонецЦикла;
	
	УправлениеЗапасамиРасширеннаяАналитика.РасчитатьЦенуНоменклатуры(СтруктураПараметров, Запрос.Текст, Запрос.Параметры);
	
	Если НЕ ВызываетсяИзФормыНастройки Тогда
		ОбъектНастройки.Разблокировать();
	КонецЕсли;	

КонецПроцедуры

Процедура ДопроведениеДокументов(Настройка) Экспорт
	// Убедимся, что ссылка соответствует существующему объекту
	Попытка
		ОбъектНастройки = Настройка.ПолучитьОбъект();
	Исключение
		ВызватьИсключение "Ошибка при получении настройки допроведения, связанной с регламентным заданием: " + ОписаниеОшибки();
	КонецПопытки;
	
	// Проверим, что по настройке включено автоматическое допроведение
	Если НЕ Настройка.ФормироватьДокументыАвтоматически Тогда
		ОбщегоНазначения.Сообщение("Для настройки допроведения, связанной с регламентным заданием, автоматическое допроведение отключено");
		Возврат;
	КонецЕсли;
	
	// Если указан запуск по числам месяца, проверим наступило ли время выполнения регламентного задания
	Если Настройка.НомерДняНачалоЗапуска <> 0 И Настройка.НомерДняКонецЗапуска <> 0 Тогда
		флНеобходимЗапуск = Ложь;
		Если Настройка.НомерДняНачалоЗапуска <= Настройка.НомерДняКонецЗапуска Тогда
			//Интервал запуска в пределах одного месяца (например с 20-го по 25-е)
			СегодняшнийДень = День(ТекущаяДата());
			Если Настройка.НомерДняНачалоЗапуска <= СегодняшнийДень И Настройка.НомерДняКонецЗапуска >= СегодняшнийДень Тогда
				флНеобходимЗапуск = Истина;
			КонецЕсли;
		Иначе
			//Интервал запуска в разных месяцах, например с 25-го по 5-е
			НачалоТекущегоМесяца = НачалоМесяца(ТекущаяДата());
			Если 
				ТекущаяДата() > НачалоТекущегоМесяца + 60*60*24 * Настройка.НомерДняНачалоЗапуска	// текущая дата в периоде с 25-го по конец месяца
				ИЛИ ТекущаяДата() < НачалоТекущегоМесяца + 60*60*24 * Настройка.НомерДняКонецЗапуска  // текущая дата в периоде с начала месяца по 5-е
				Тогда
				флНеобходимЗапуск = Истина;
			КонецЕсли;
		КонецЕсли;
		Если НЕ флНеобходимЗапуск Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Заблокируем объект настройки
	ОбъектНастройки.Заблокировать();
	
	ПериодДопроведения 		= ОтложенноеПроведениеДокументов.ОпределитьПериодДопроведения(Настройка);
	НачалоИнтервалаДопроведения 	= ПериодДопроведения.НачалоИнтервала;
	КонецИнтервалаДопроведения 	= ПериодДопроведения.КонецИнтервала;
	
	//Определим список организаций
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ РАЗРЕШЕННЫЕ
	|	Организация,
	|	ДатаНачалаДействия КАК ДатаНачалаОтложенногоПроведения
	|ИЗ
	|	РегистрСведений.НастройкаОтложенногоПроведения
	|ГДЕ НастройкаДопроведенияДокументов = &ТекНастройка
	|УПОРЯДОЧИТЬ ПО Организация";
	Запрос.УстановитьПараметр("ТекНастройка", Настройка);
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ОбщегоНазначения.Сообщение("Настройка допроведения не назначена ни одной организации");
		Возврат;
	КонецЕсли;
	ТаблицаОрганизаций = РезультатЗапроса.Выгрузить();
	ПараметрыДопроведения = Новый Структура("ДопроводитьВсеДокументы, 
							|ДатаНачала, ДатаОкончания", 
							Настройка.ДопроводитьВсеДокументы, НачалоДня(НачалоИнтервалаДопроведения), 
							КонецДня(КонецИнтервалаДопроведения));

	ОтложенноеПроведениеДокументов.ВыполнитьДопроведениеДокументовПоСпискуОрганизаций(ТаблицаОрганизаций, ПараметрыДопроведения);

	ОбъектНастройки.Разблокировать();
КонецПроцедуры

Процедура ОбновлениеАгрегатов() Экспорт
	Для Каждого ТекущийРегистр Из Метаданные.РегистрыНакопления Цикл
		Если ТекущийРегистр.ВидРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Обороты Тогда
			Если РегистрыНакопления[ТекущийРегистр.Имя].ПолучитьРежимАгрегатов()
			  И РегистрыНакопления[ТекущийРегистр.Имя].ПолучитьИспользованиеАгрегатов() Тогда
			  	РегистрыНакопления[ТекущийРегистр.Имя].ОбновитьАгрегаты();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

Процедура ПерестроениеАгрегатов() Экспорт
	Для Каждого ТекущийРегистр Из Метаданные.РегистрыНакопления Цикл
		Если ТекущийРегистр.ВидРегистра = Метаданные.СвойстваОбъектов.ВидРегистраНакопления.Обороты Тогда
			Если РегистрыНакопления[ТекущийРегистр.Имя].ПолучитьРежимАгрегатов()
			  И РегистрыНакопления[ТекущийРегистр.Имя].ПолучитьИспользованиеАгрегатов() Тогда
			  	РегистрыНакопления[ТекущийРегистр.Имя].ПерестроитьИспользованиеАгрегатов();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
КонецПроцедуры

