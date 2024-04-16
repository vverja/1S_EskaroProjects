&НаСервере
Функция НайтиНастройкуПоИмени(ИмяСохраняемойНастройки)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СписокНастроек.ССылка КАК Ссылка
	|ИЗ
	|	Справочник.НастройкиФормированияДокументовПоОрдерам КАК СписокНастроек
	|ГДЕ
	|	(НЕ СписокНастроек.ПометкаУдаления)
	|	И СписокНастроек.Наименование = &Наименование
	|	И (НЕ СписокНастроек.ЭтоГруппа)";
				   
	Запрос.Параметры.Вставить("Наименование", ИмяСохраняемойНастройки);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Возврат Строка(Выборка.Ссылка.УникальныйИдентификатор());
	КонецЕсли;
		
КонецФункции


&НаКлиенте
Процедура СохранитьВыполнить()
	
	Если ИмяСохраняемойНастройки = "" тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НСтр("ru = 'Не задано название настройки.'"),, "НазваниеНастройки");
		Возврат;
	КонецЕсли;
	
	ИдентификаторСохраняемойНастройки = НайтиНастройкуПоИмени(ИмяСохраняемойНастройки);
	
	Если ИдентификаторСохраняемойНастройки <> Неопределено Тогда
		// Уже была настройка с таким именем. Спросим у пользователя, нужно ли перезаписать старую настройку.
		СтрокаВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("ru='Заменить настройку %1?'", ИмяСохраняемойНастройки);
		
		Если Вопрос(Нстр(СтрокаВопроса), РежимДиалогаВопрос.ДаНет) <> КодВозвратаДиалога.Да Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	//Зафиксируем в форме журнала ордеров выбранную настройку
	ВладелецФормы.ТекущаяНастройка = ИмяСохраняемойНастройки;
	ВладелецФормы.КлючТекущейНастройки = ИдентификаторСохраняемойНастройки;
	
	Закрыть(Новый ВыборНастроек(ИдентификаторСохраняемойНастройки));
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
//                                                         

&НаСервере
Процедура ПриСоздании(Отказ, СтандартнаяОбработка)
	
	Перем КлючТекущихНастроек;
	
	КлючТекущихНастроек = Параметры.КлючТекущихНастроек;
	
	ЗаполнитьСписок();
	
	Элемент = ХранилищаНастроек.НастройкиФормированияРегулярныхДокументов.ПолучитьСсылкуПоКлючуТекущейНастройки(КлючТекущихНастроек);
	
	ЭлементСписка = СписокНастроек.НайтиПоЗначению(КлючТекущихНастроек);

	Если Элемент <> Справочники.НастройкиФормированияДокументовПоОрдерам.ПустаяСсылка() И ЭлементСписка <> Неопределено Тогда
		ИндексСтроки = СписокНастроек.Индекс(ЭлементСписка);
		Элементы.СписокНастроек.ТекущаяСтрока = ИндексСтроки;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписок()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	СписокНастроек.ССылка КАК Ссылка,
	|	СписокНастроек.Наименование КАК Наименование
	|ИЗ
	|	Справочник.НастройкиФормированияДокументовПоОрдерам КАК СписокНастроек
	|ГДЕ
	|	(НЕ СписокНастроек.ПометкаУдаления)
	|	И (НЕ СписокНастроек.ЭтоГруппа)";

	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();

	СписокНастроек.Очистить();
	Пока Выборка.Следующий() Цикл
		СписокНастроек.Добавить(Строка(Выборка.Ссылка.УникальныйИдентификатор()), Выборка.Наименование);
	КонецЦикла;                                                       
	
	СписокНастроек.СортироватьПоПредставлению();
КонецПроцедуры

&НаКлиенте
Процедура СписокНастроекПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные <> Неопределено Тогда
		ИмяСохраняемойНастройки = Элемент.ТекущиеДанные.Представление;
	Иначе
		ИмяСохраняемойНастройки = "";
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура УдалитьВыполнить()
	ВыполнитьКомандуУдалить();
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуУдалить()
	ИдентификаторСохраняемойНастройки = НайтиНастройкуПоИмени(ИмяСохраняемойНастройки);
	Если ИдентификаторСохраняемойНастройки <> Неопределено Тогда
		УдалитьНастройку(ИдентификаторСохраняемойНастройки);
		ЗаполнитьСписок();
	КонецЕсли;
КонецПроцедуры


&НаСервере
Процедура УдалитьНастройку(КлючНастройки)
	
	ИдентификаторУдаляемойНастройки = Новый УникальныйИдентификатор(КлючНастройки);
	
	Элемент = Справочники.НастройкиФормированияДокументовПоОрдерам.ПолучитьСсылку(ИдентификаторУдаляемойНастройки);
	Объект = Элемент.ПолучитьОбъект();
	Объект.Заблокировать();
	Объект.УстановитьПометкуУдаления(Истина);
КонецПроцедуры

&НаКлиенте
Процедура НастройкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СохранитьВыполнить();	
КонецПроцедуры
