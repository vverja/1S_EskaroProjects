Функция ПолучитьТекущегоРаботника() Экспорт 
    Пользователь = ПараметрыСеанса.ТекущийПользователь;
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    РаботникиТабличнаяЧастьРаботников.Сотрудник,
                   |    РаботникиТабличнаяЧастьРаботников.ТипРаботника,
                   |    РаботникиТабличнаяЧастьРаботников.Ссылка.Склад
                   |ИЗ
                   |    Справочник.Работники.ТабличнаяЧастьРаботников КАК РаботникиТабличнаяЧастьРаботников
                   |ГДЕ
                   |    РаботникиТабличнаяЧастьРаботников.Пользователь = &Пользователь";
    Запрос.УстановитьПараметр("Пользователь", Пользователь);
    Выборка = Запрос.Выполнить().Выбрать();
    РаботникИСклад = Новый Структура;
    Если Выборка.Следующий() Тогда
        РаботникИСклад.Вставить("Работник", Выборка.Сотрудник);
        РаботникИСклад.Вставить("ТипРаботника", Выборка.ТипРаботника);
        РаботникИСклад.Вставить("Склад", Выборка.Склад);
        Возврат РаботникИСклад;       
    КонецЕсли; 
    Возврат Неопределено;
КонецФункции
  
Функция ЗаписатьДанныеВБазу(ПостЗапрос) Экспорт
    СтруктураОтвета = Новый Структура;
    СтруктураОтвета.Вставить("error", Ложь);
    СтруктураОтвета.Вставить("message","");
    СтруктураЗапроса = СформироватьСтруктуруИзЗапроса(ПостЗапрос);
    Для каждого СтруктураЗадание Из СтруктураЗапроса.taskList Цикл        
        Если НЕ ЭтоИнвентаризация(СтруктураЗадание) И ОпределитьНеобходимостьУдаленияЗаданияИзУстройства(СтруктураЗадание) Тогда //
            СтруктураОтвета.message = СтруктураОтвета.message + СтруктураЗадание.task_uuid + ";"; // Задания которые необходимо удалить                    
            Продолжить;
        КонецЕсли; 	        
        Попытка
    	    ЗаписатьДокументИзСтруктуры(СтруктураЗадание);
        Исключение
            СтруктураОтвета.Вставить("message", ОписаниеОшибки());
            СтруктураОтвета.Вставить("error", Истина);
            Прервать;
        КонецПопытки;
    КонецЦикла;
    возврат СтруктураОтвета;
КонецФункции
     
Функция ОпределитьНеобходимостьУдаленияЗаданияИзУстройства(СтруктураЗадание)
    СсылкаНаЗадание = ПолучитьЗаданиеВБазе(СтруктураЗадание);
    Если СсылкаНаЗадание = Неопределено Тогда
        Возврат Истина;
    КонецЕсли;  
    Если СтруктураЗадание.executor = "" Тогда
        Возврат НЕ ПустаяСтрока(СсылкаНаЗадание.Исполнитель);
    Иначе
        Возврат СокрЛП(СсылкаНаЗадание.Исполнитель) <> СокрЛП(СтруктураЗадание.executor) И НЕ ПустаяСтрока(СсылкаНаЗадание.Исполнитель);
    КонецЕсли; 
    Возврат Ложь;
КонецФункции

Функция ПолучитьЗаданиеВБазе(СтруктураЗадание)
    Объект = Документы.ЗаданиеНаРаботу.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураЗадание.task_uuid));
    Если Найти(Строка(Объект.Ссылка), "Объект не найден") <> 0 Тогда
        Возврат Неопределено;	
    КонецЕсли;
    Возврат Объект;
КонецФункции
 
Функция ПолучитьЗаданияДляПроверки(ГетЗапрос) Экспорт
    УИД = ГетЗапрос.ПараметрыURL["UUID"];    
    Запрос = Новый Запрос;
    Запрос.Текст = 
        "ВЫБРАТЬ
        |   ЗаданиеНаРаботу.Ссылка
        |ИЗ
        |   Документ.ЗаданиеНаРаботу КАК ЗаданиеНаРаботу
        |ГДЕ
        |   ЗаданиеНаРаботу.УИД = &УИД
        |   И ЗаданиеНаРаботу.ВидЗадания <> ""Проверка""";

    Запрос.УстановитьПараметр("УИД", УИД);

    Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);
    
КонецФункции

Функция ПолучитьАктуальныеЗадания(СтруктураРаботникИСклад)Экспорт
    СтрокаОтбораПоВидуЗадания = "";
    Если СтруктураРаботникИСклад.ТипРаботника = "Комплектовщик"  Тогда
        СтрокаОтбораПоВидуЗадания = "И (ВидЗадания = ""Отгрузка"" ИЛИ ВидЗадания = ""Перемещение"")";    	
    ИначеЕсли СтруктураРаботникИСклад.ТипРаботника = "Кладовщик" Тогда
        СтрокаОтбораПоВидуЗадания = "И (ВидЗадания = ""Отгрузка"" ИЛИ ВидЗадания = ""Приемка"" ИЛИ ВидЗадания = ""Проверка"" ИЛИ ВидЗадания = ""Перемещение"")";    	
    ИначеЕсли СтруктураРаботникИСклад.ТипРаботника = "Ричтрак" Тогда
        СтрокаОтбораПоВидуЗадания = "И ВидЗадания = ""Перемещение""";    	                    
    КонецЕсли; 
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    ЗаданиеНаРаботу.Ссылка
                   |ИЗ
                   |    Документ.ЗаданиеНаРаботу КАК ЗаданиеНаРаботу
                   |ГДЕ
                   |    (ЗаданиеНаРаботу.Исполнитель = &Исполнитель
                   |            ИЛИ ЗаданиеНаРаботу.Исполнитель = """")
                   |    И ЗаданиеНаРаботу.ВремяНачалообработки = ДАТАВРЕМЯ(1, 1, 1)
                   |    И ЗаданиеНаРаботу.Склад = &Склад " + СтрокаОтбораПоВидуЗадания + "    
                   |
                   |УПОРЯДОЧИТЬ ПО
                   |    ЗаданиеНаРаботу.Дата";
    Запрос.УстановитьПараметр("Исполнитель", СтруктураРаботникИСклад.Работник.Наименование);
    Запрос.УстановитьПараметр("Склад", Лев(СтруктураРаботникИСклад.Склад.Наименование, 20));
    Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку(0);  		
КонецФункции
 

Функция КонвертироватьТаскВСтруктуру(Документ) Экспорт
         
    ЗапросПоШтрихкодам = новый Запрос;
    ЗапросПоШтрихкодам.Текст = "ВЫБРАТЬ
                               |    Штрихкоды.Штрихкод,
                               |    Номенклатура.Код КАК КодНоменклатуры
                               |ИЗ
                               |    РегистрСведений.Штрихкоды КАК Штрихкоды
                               |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
                               |        ПО Штрихкоды.Владелец = Номенклатура.Ссылка
                               |            И Штрихкоды.ЕдиницаИзмерения = Номенклатура.ЕдиницаХраненияОстатков
                               |ГДЕ
                               |    Номенклатура.Код В(&СписокНоменклатуры)";
    
    ЗапросПоШтрихкодам.УстановитьПараметр("СписокНоменклатуры", Документ.Задание.ВыгрузитьКолонку("КодНоменклатуры"));
    тзШК = ЗапросПоШтрихкодам.Выполнить().Выгрузить();
    
    Структура = Новый Структура;
    Структура.Вставить("task_uuid", Строка(Документ.Ссылка.УникальныйИдентификатор()));
    Структура.Вставить("task_number", Документ.Номер);
    Структура.Вставить("task_date", Документ.Дата);
    Структура.Вставить("basis_doc", Документ.ДокументОснование);
    Структура.Вставить("order_number", Документ.НомерЗаказа);
    Структура.Вставить("task_type", Документ.ВидЗадания);
    Структура.Вставить("consumer", Документ.ПоставщикПолучатель);
    Структура.Вставить("shop", Документ.ТорговаяТочка);
    Структура.Вставить("executor", Документ.Исполнитель);
    Структура.Вставить("begin_time", Документ.ВремяНачалообработки);
    Структура.Вставить("end_time", Документ.ВремяОкончанияОбработки);
    Структура.Вставить("stock", Документ.Склад);
    Структура.Вставить("comments", Документ.Комментарий);
    Структура.Вставить("basis_doc_uuid", Документ.УИД);
    Структура.Вставить("package_list_present", Документ.ИспользуемУпаковочныйЛист);
    Структура.Вставить("upload", Документ.Выгружать);
    МассивСтрок = Новый Массив;
    
    Для каждого ТабСтрока Из Документ.Задание Цикл
        СтруктураСтроки = Новый Структура;
        СтруктураСтроки.Вставить("row_number", ТабСтрока.НомерСтроки);
        СтруктураСтроки.Вставить("item_code",ТабСтрока.КодНоменклатуры);
        СтруктураСтроки.Вставить("item_name",ТабСтрока.Номенклатура);
        НС = тзШК.Найти(ТабСтрока.КодНоменклатуры, "КодНоменклатуры");
        Если НС <> Неопределено Тогда
            СтруктураСтроки.Вставить("item_barcode",НС.Штрихкод);
        Иначе
            СтруктураСтроки.Вставить("item_barcode","");
        КонецЕсли;  
        СтруктураСтроки.Вставить("item_unit",ТабСтрока.ЕдиницаИзмерения);
        СтруктураСтроки.Вставить("item_factor",ТабСтрока.Коэффициент);
        СтруктураСтроки.Вставить("item_qty_plan",ТабСтрока.Количество);
        СтруктураСтроки.Вставить("item_qty_fact",ТабСтрока.КоличествоФакт);
        СтруктураСтроки.Вставить("pallet_number",ТабСтрока.НомерПаллета);
        СтруктураСтроки.Вставить("zone",ТабСтрока.Зона);
        СтруктураСтроки.Вставить("cell_type",ТабСтрока.ВидЯчейки);
        СтруктураСтроки.Вставить("cell_plan_from",ТабСтрока.ЯчейкаПлан);
        СтруктураСтроки.Вставить("cell_plan_where",ТабСтрока.ЯчейкаПланКуда);
        СтруктураСтроки.Вставить("route_number",ТабСтрока.НомерМаршрута);
        СтруктураСтроки.Вставить("collector",ТабСтрока.КтоСобирал);
        СтруктураСтроки.Вставить("error",ТабСтрока.Ошибка);
        СтруктураСтроки.Вставить("pallet_qty",ТабСтрока.КолПаллет);
        СтруктураСтроки.Вставить("package_qty",ТабСтрока.КолУпак);
        СтруктураСтроки.Вставить("without_package_qty",ТабСтрока.КолБезУпак);
        СтруктураСтроки.Вставить("in_package_qty",ТабСтрока.КолВУпак);
        СтруктураСтроки.Вставить("in_pallet_qty",ТабСтрока.КолВПаллете);
        СтруктураСтроки.Вставить("adjunction",ТабСтрока.Пополнение);
        СтруктураСтроки.Вставить("done",ТабСтрока.Выполнено);
        СтруктураСтроки.Вставить("package_list_number",ТабСтрока.УпаковочныйЛист);
        МассивСтрок.Добавить(СтруктураСтроки);
    КонецЦикла; 
    Структура.Вставить("goods", МассивСтрок); 
    Возврат Структура; 
КонецФункции


Функция КонвертироватьИнвентаризациюВСтруктуру(Документ) Экспорт
    ЗапросПоШтрихкодам = новый Запрос;
    ЗапросПоШтрихкодам.Текст = "ВЫБРАТЬ
                               |    Штрихкоды.Штрихкод,
                               |    Номенклатура.Ссылка КАК Номенклатура
                               |ИЗ
                               |    РегистрСведений.Штрихкоды КАК Штрихкоды
                               |        ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
                               |        ПО Штрихкоды.Владелец = Номенклатура.Ссылка
                               |ГДЕ
                               |    Номенклатура.Ссылка В(&СписокНоменклатуры)";
    
    ЗапросПоШтрихкодам.УстановитьПараметр("СписокНоменклатуры", Документ.Ссылка.Товары.ВыгрузитьКолонку("Номенклатура"));
    тзШК = ЗапросПоШтрихкодам.Выполнить().Выгрузить();
    
    Структура = Новый Структура;
    Структура.Вставить("doc_uui", Строка(Документ.Ссылка.УникальныйИдентификатор()));
    Структура.Вставить("doc_number", Документ.Номер);
    Структура.Вставить("doc_date", Документ.Дата);
    Структура.Вставить("executor", Документ.Планшет.Наименование);
    Структура.Вставить("commission_member", Документ.ИсполнительИнвентаризации.Наименование);
    Структура.Вставить("stock", Документ.Склад.Наименование);
    Структура.Вставить("is_finished", Документ.Статус = Перечисления.СтатусыСкладскихПеремещений.Завершено);
    Структура.Вставить("reloading", Документ.ПовторнаяВыгрузка);    
    Структура.Вставить("comments", Документ.Комментарий);
    МассивСтрок = Новый Массив;
    Если Документ.ПечатьСПустымиЯчейками Тогда
        Товары = Обмен.СформироватьТаблицуТоваров(Документ.Ссылка);
    Иначе
        Товары =  Документ.Товары; 
    КонецЕсли;
    Для каждого ТабСтрока Из Товары Цикл
        Если Документ.ПовторнаяВыгрузка Тогда
            Если ТабСтрока.ОтклонениеЕХО = 0 Тогда
                Продолжить;
            КонецЕсли;
        КонецЕсли;
        СтруктураСтроки = Новый Структура;
        СтруктураСтроки.Вставить("row_number", ТабСтрока.НомерСтроки);
        СтруктураСтроки.Вставить("item_code", ТабСтрока.Номенклатура.Код);
        СтруктураСтроки.Вставить("item_name", ТабСтрока.Номенклатура.Наименование);
        НС = тзШК.Найти(ТабСтрока.Номенклатура, "Номенклатура");
        Если НС <> Неопределено Тогда
            СтруктураСтроки.Вставить("item_barcode",НС.Штрихкод);
        Иначе
            СтруктураСтроки.Вставить("item_barcode","");
        КонецЕсли;  
        СтруктураСтроки.Вставить("item_unit",ТабСтрока.ЕдиницаХраненияОстатков.Наименование);
        СтруктураСтроки.Вставить("item_factor",ТабСтрока.Коэффициент);
        СтруктураСтроки.Вставить("item_qty", 0);
        СтруктураСтроки.Вставить("cell_name",ТабСтрока.УчетнаяЯчейка.Наименование);
        СтруктураСтроки.Вставить("remark",ТабСтрока.Примечание);
        СтруктураСтроки.Вставить("doc_uui", Строка(Документ.Ссылка.УникальныйИдентификатор()));
        МассивСтрок.Добавить(СтруктураСтроки);
    КонецЦикла; 
    Структура.Вставить("body_list", МассивСтрок); 
    Возврат Структура; 
КонецФункции


Процедура ЗаписатьДокументИзСтруктуры(СтруктураДокумента) 
    Перем Ссылка;
    Если ЭтоИнвентаризация(СтруктураДокумента) Тогда
        Ссылка = ПолучитьИнвентаризациюВБазе(СтруктураДокумента); // не должно прилетать неопределено, ранее проверено
        Документ =  Ссылка.ПолучитьОбъект();
        СкопироватьДанныеИзСтруктурыВДокументИнвентаризация(Документ, СтруктураДокумента);
    Иначе
        Ссылка = ПолучитьЗаданиеВБазе(СтруктураДокумента); // не должно прилетать неопределено, ранее проверено    
        Документ =  Ссылка.ПолучитьОбъект();
        СкопироватьДанныеИзСтруктурыВДокументЗадание(Документ, СтруктураДокумента);
        Если Документ.ВремяОкончанияОбработки <> Дата(1,1,1) Тогда
            Обмен.ОбработкаЗаданийНаРаботу(Документ);  	
        КонецЕсли;         
    КонецЕсли;    
КонецПроцедуры

Процедура СкопироватьДанныеИзСтруктурыВДокументЗадание(Документ, Структура)
    Документ.ВремяНачалообработки = ПолучитьДатуИзСтроки(Структура.begin_time);
    Документ.ВремяОкончанияОбработки = ПолучитьДатуИзСтроки(Структура.end_time);
    Документ.Комментарий = Структура.comments;
    Если ПустаяСтрока(Документ.Исполнитель) Тогда
        СтруктураРаботникИСклад = ПолучитьТекущегоРаботника(); 
    	Документ.Исполнитель = СтруктураРаботникИСклад.Работник.Наименование;
    КонецЕсли; 
    МассивСтрок = Новый Массив;
    Для каждого ТабСтрока Из Структура.goods Цикл
        НайденнаяСтрокаДокумента = Документ.Задание.Найти(ТабСтрока.row_number, "НомерСтроки");
        Если НайденнаяСтрокаДокумента <> Неопределено Тогда
            НайденнаяСтрокаДокумента.КоличествоФакт = ТабСтрока.item_qty_fact;
            НайденнаяСтрокаДокумента.Ошибка = ТабСтрока.error;
            НайденнаяСтрокаДокумента.Выполнено = ТабСтрока.Done;
        КонецЕсли; 
    КонецЦикла;
    Документ.Записать();
КонецПроцедуры

Процедура СкопироватьДанныеИзСтруктурыВДокументИнвентаризация(Документ, Структура)
    Если Структура.is_finished Тогда
        Документ.СтатусОбработкиНаПланшете = Перечисления.СтатусыСкладскихПеремещений.Завершено;
    Иначе
        Документ.СтатусОбработкиНаПланшете = Перечисления.СтатусыСкладскихПеремещений.Выполнение;
    КонецЕсли; 
    Документ.Комментарий = Структура.comments;
    Для каждого ТабСтрока Из Структура.body_list Цикл
        НайденнаяСтрокаДокумента = Документ.Товары.Найти(ТабСтрока.row_number, "НомерСтроки");
        Если НайденнаяСтрокаДокумента <> Неопределено Тогда
            НайденнаяСтрокаДокумента.ФактическоеКоличествоЕХО = ТабСтрока.item_qty;
            НайденнаяСтрокаДокумента.ОтклонениеЕХО = НайденнаяСтрокаДокумента.ФактическоеКоличествоЕХО - НайденнаяСтрокаДокумента.УчетноеКоличествоЕХО
        КонецЕсли; 
    КонецЦикла;
    Документ.Записать();
КонецПроцедуры

Функция ПолучитьДатуИзСтроки(ДатаСтрока)    
    ДатаСтрока = СтрЗаменить(ДатаСтрока,"-","");
	ДатаСтрока = СтрЗаменить(ДатаСтрока,":","");
    ДатаСтрока = СтрЗаменить(ДатаСтрока," ","");
    ДатаСтрока = СтрЗаменить(ДатаСтрока,"T","");
    Попытка
        Результат = Дата(ДатаСтрока);	
    Исключение
        Результат = Дата(1,1,1);
    КонецПопытки; 
    
    Возврат Результат; 
КонецФункции

Функция фПрочитатьJSON(ТекстJSON) Экспорт
	Чтение = Новый ЧтениеJSON;
	Чтение.УстановитьСтроку(ТекстJSON);
	Структура = ЗаполнитьСтруктуруИзОтветаJSON(Чтение);	
	Чтение.Закрыть();
	Возврат Структура;
КонецФункции

Функция ЗаполнитьСтруктуруИзОтветаJSON(Знач Чтение) Экспорт
	Результат = Новый Структура;

	ПоследнееИмяРеквизита = Неопределено;
	
	Пока Чтение.Прочитать() Цикл
		Тип = Чтение.ТипТекущегоЗначения;
		Если Тип = ТипЗначенияJSON.НачалоОбъекта И ПоследнееИмяРеквизита<>Неопределено Тогда 
			Результат[ПоследнееИмяРеквизита] = ЗаполнитьСтруктуруИзОтветаJSON(Чтение);
		ИначеЕсли Тип = ТипЗначенияJSON.КонецОбъекта Тогда 
			Возврат Результат;
			ПоследнееИмяРеквизита = Неопределено;
		ИначеЕсли Тип = ТипЗначенияJSON.ИмяСвойства Тогда 
			Результат.Вставить(Чтение.ТекущееЗначение, Неопределено);
			ПоследнееИмяРеквизита = Чтение.ТекущееЗначение;
		ИначеЕсли Тип = ТипЗначенияJSON.Булево или Тип = ТипЗначенияJSON.Строка
			или Тип = ТипЗначенияJSON.Число или Тип = ТипЗначенияJSON.Null Тогда 
			Результат[ПоследнееИмяРеквизита] = Чтение.ТекущееЗначение;
        ИначеЕсли Тип = ТипЗначенияJSON.НачалоМассива Тогда 
			Результат[ПоследнееИмяРеквизита] = ЗаполнитьМассивИзОтветаJSON(Чтение);
		КонецЕсли;
	КонецЦикла;  
		
	Возврат Результат;
КонецФункции 

Функция ЗаполнитьМассивИзОтветаJSON(Знач Чтение)
	Результат = Новый Массив;
	
	Пока Чтение.Прочитать() Цикл
		Тип = Чтение.ТипТекущегоЗначения;
		Если Тип = ТипЗначенияJSON.НачалоОбъекта Тогда 
			Результат.Добавить(ЗаполнитьСтруктуруИзОтветаJSON(Чтение));
        ИначеЕсли Тип = ТипЗначенияJSON.КонецМассива Тогда 
			Возврат Результат;
        ИначеЕсли Тип = ТипЗначенияJSON.Строка Тогда 
            Результат.Добавить(Чтение.ТекущееЗначение);
		КонецЕсли;
	КонецЦикла;  
	
	Возврат Результат;
КонецФункции

Функция СформироватьСтруктуруИзЗапроса(ПостЗапрос) Экспорт
    ТелоЗапроса = ПостЗапрос.ПолучитьТелоКакСтроку();
    Если ЗначениеЗаполнено(ТелоЗапроса) Тогда
        Возврат фПрочитатьJSON(ТелоЗапроса);
    КонецЕсли;
    Возврат Неопределено;
КонецФункции

Функция КонтрольныйСимволEAN(ШтрихКод, Тип) Экспорт
	Четн   = 0;
	Нечетн = 0;

	КоличествоИтераций = ?(Тип = 13, 6, 4);

	Для Индекс = 1 По КоличествоИтераций Цикл
		Если (Тип = 8) и (Индекс = КоличествоИтераций) Тогда
		Иначе
			Четн   = Четн   + Сред(ШтрихКод, 2 * Индекс, 1);
		КонецЕсли;
		Нечетн = Нечетн + Сред(ШтрихКод, 2 * Индекс - 1, 1);
	КонецЦикла;

	Если Тип = 13 Тогда
		Четн = Четн * 3;     
	Иначе
		Нечетн = Нечетн * 3;
	КонецЕсли;

	КонтЦифра = 10 - (Четн + Нечетн) % 10;

	Возврат ?(КонтЦифра = 10, "0", Строка(КонтЦифра));
КонецФункции

Функция УбратьНули(НомерСтрокой) Экспорт
    Если Лев(НомерСтрокой, 1) = "0" Тогда
        Возврат УбратьНули(Прав(НомерСтрокой, СтрДлина(НомерСтрокой) - 1)); 
    Иначе
        Возврат НомерСтрокой;
    КонецЕсли;
КонецФункции


Функция ПреобразоватьВыборкуВСтрукутуру(Выборка) Экспорт
    Результат = Новый Структура;
	Для каждого Колонка Из Выборка.Владелец().Колонки Цикл
        Результат.Вставить(Колонка.Имя);
    КонецЦикла; 
    Если Выборка.Следующий() Тогда
        ЗаполнитьЗначенияСвойств(Результат, Выборка);	
        Возврат Результат;
    КонецЕсли; 
    Возврат Неопределено; 
КонецФункции
 
Функция ПолучитьАктуальныеИнвентаризаци(СтруктураРаботникИСклад) Экспорт
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    Инвентаризация.Ссылка
                   |ИЗ
                   |    Документ.Инвентаризация КАК Инвентаризация
                   |ГДЕ
                   |    Инвентаризация.Планшет = &Планшет
                   |    И Инвентаризация.Склад = &Склад
                   |    И Инвентаризация.СтатусОбработкиНаПланшете = &Статус
                   |    И Инвентаризация.Статус <> &СтатусДокумента";
    Запрос.УстановитьПараметр("Планшет",СтруктураРаботникИСклад.Работник );
    Запрос.УстановитьПараметр("Склад",СтруктураРаботникИСклад.Склад );
    Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыСкладскихПеремещений.ПустаяСсылка());
    Запрос.УстановитьПараметр("СтатусДокумента", Перечисления.СтатусыСкладскихПеремещений.Завершено);
    Возврат Запрос.Выполнить().Выгрузить();         
КонецФункции


Функция ПреобразоватьВыборкуВМассивСтруктур(Выборка) Экспорт
    Результат = Новый Массив;
    СтруктураОтвета = Новый Структура;
    Для каждого Колонка Из Выборка.Владелец().Колонки Цикл
        СтруктураОтвета.Вставить(Колонка.Имя);
    КонецЦикла; 
    Пока Выборка.Следующий() Цикл
	    СтруктураСтроки = Новый Структура(СтруктураОтвета);
        ЗаполнитьЗначенияСвойств(СтруктураСтроки, Выборка);	
        Результат.Добавить(СтруктураСтроки);
    КонецЦикла; 
    Возврат Результат; 
КонецФункции


Функция ЭтоИнвентаризация(СтруктураДокумента)
	Если СтруктураДокумента.Свойство("end_time") Тогда
    	Возврат Ложь;
    КонецЕсли; 
    Возврат Истина;
КонецФункции
 
Функция ПолучитьИнвентаризациюВБазе(СтруктураДокумента)
    Объект = Документы.Инвентаризация.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураДокумента.doc_uui));
    Если Найти(Строка(Объект.Ссылка), "Объект не найден") <> 0 Тогда
        Возврат Неопределено;	
    КонецЕсли;
    Возврат Объект;	
КонецФункции
 
Функция ПолучитьНоменклатуруПоШтрихкоду(ГетЗапрос) Экспорт
    СтруктураСтроки = Новый Структура;
    СтруктураСтроки.Вставить("item_code", "");
    СтруктураСтроки.Вставить("item_name", "");
    СтруктураСтроки.Вставить("item_barcode", "");
    СтруктураСтроки.Вставить("item_unit", "");
    СтруктураСтроки.Вставить("item_factor", "");
    
    Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    Штрихкоды.Владелец.Код КАК item_code,
                   |    Штрихкоды.Владелец.Наименование КАК item_name,
                   |    Штрихкоды.ЕдиницаИзмерения.Наименование КАК item_unit,
                   |    Штрихкоды.ЕдиницаИзмерения.Коэффициент КАК item_factor,
                   |    Штрихкоды.Штрихкод КАК item_barcode
                   |ИЗ
                   |    РегистрСведений.Штрихкоды КАК Штрихкоды
                   |ГДЕ
                   |    Штрихкоды.Штрихкод = &Штрихкод";
    Запрос.УстановитьПараметр("Штрихкод", СокрЛП(ГетЗапрос.ПараметрыURL["code"]));
    Выборка = Запрос.Выполнить().Выбрать();
    Если Выборка.Следующий() Тогда
        ЗаполнитьЗначенияСвойств(СтруктураСтроки, Выборка);      	
    КонецЕсли; 
    Возврат СтруктураСтроки;
КонецФункции

Функция ПолучитьСписокНоменклатуры() Экспорт    
    СписокНоменклатуры = Новый Массив;
    СтруктураОтвета = Новый Структура;
    СтруктураОтвета.Вставить("items_list",СписокНоменклатуры);

    
    МассивВидовНоменклатуры = Новый Массив;
    МассивВидовНоменклатуры.Добавить(Справочники.ВидыНоменклатуры.НайтиПоКоду("000000001"));
    МассивВидовНоменклатуры.Добавить(Справочники.ВидыНоменклатуры.НайтиПоКоду("000000008"));
    МассивВидовНоменклатуры.Добавить(Справочники.ВидыНоменклатуры.НайтиПоКоду("000000009"));    
    
	Запрос = Новый Запрос;
    Запрос.Текст = "ВЫБРАТЬ
                   |    Штрихкоды.Владелец.Код КАК item_code,
                   |    Штрихкоды.Владелец.Наименование КАК item_name,
                   |    Штрихкоды.Владелец.ЕдиницаХраненияОстатков.Наименование КАК item_unit,
                   |    Штрихкоды.Владелец.ЕдиницаХраненияОстатков.Коэффициент КАК item_factor,
                   |    Штрихкоды.Штрихкод КАК item_barcode
                   |ИЗ
                   |    РегистрСведений.Штрихкоды КАК Штрихкоды
                   |ГДЕ
                   |    Штрихкоды.Владелец.ВидНоменклатуры В(&СписокВидовНоменклатуры)
                   |    И НЕ Штрихкоды.Владелец.Наименование ПОДОБНО ""я_%""
                   |    И НЕ Штрихкоды.Владелец.Наименование ПОДОБНО ""я %""
                   |    И НЕ Штрихкоды.Владелец.Наименование ПОДОБНО ""ъ%""
                   |    И НЕ Штрихкоды.Владелец.Родитель.Наименование ПОДОБНО ""%неакт""
                   |
                   |УПОРЯДОЧИТЬ ПО
                   |    item_name";
    Запрос.УстановитьПараметр("СписокВидовНоменклатуры", МассивВидовНоменклатуры);
    Выборка = Запрос.Выполнить().Выбрать();
    Пока  Выборка.Следующий() Цикл
        СтруктураСтроки = Новый Структура;
        СтруктураСтроки.Вставить("item_code", "");
        СтруктураСтроки.Вставить("item_name", "");
        СтруктураСтроки.Вставить("item_barcode", "");
        СтруктураСтроки.Вставить("item_unit", "");
        СтруктураСтроки.Вставить("item_factor", "");
        ЗаполнитьЗначенияСвойств(СтруктураСтроки, Выборка);      	
        СписокНоменклатуры.Добавить(СтруктураСтроки);
    КонецЦикла; 
    Возврат СтруктураОтвета;	
КонецФункции
 
 