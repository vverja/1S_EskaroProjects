#Если Клиент Тогда

Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	ПостроительОтчета = ОбщийОтчет.ПостроительОтчета;
	
	СтруктураПредставлениеПолей = Новый Структура;
	МассивОтбора = Новый Массив;
	ОбщийОтчет.мСоответствиеНазначений = Новый Соответствие;
	ОбщийОтчет.мСтруктураДляОтбораПоКатегориям = Новый Структура;
	
	
	Текст = "
	|ВЫБРАТЬ
	|	ВложенныйКорректировки.Организация							КАК Организация,
	|	ВложенныйКорректировки.ТипОбъекта							КАК ТипОбъекта,
	|	ВложенныйКорректировки.ОбъектКорректировки					КАК ОбъектКорректировки,
	|	СУММА(ВложенныйКорректировки.НДСКредит)                     КАК НДСКредитПоступление,
	|	СУММА(ВложенныйКорректировки.НДСКредитПоФакту)             	КАК НДСКредитПоФакту,		
	|	СУММА(ВложенныйКорректировки.НДСКредитПодтвержденный)       КАК НДСКредитПодтвержденный,
	|	СУММА(ВложенныйКорректировки.НДСКредитПодтвержденный - ВложенныйКорректировки.НДСКредит)   КАК НДСКредитКорректировка
	|{ВЫБРАТЬ 
	|	ВложенныйКорректировки.ТипОбъекта.*				КАК ТипОбъекта,
	|	ВложенныйКорректировки.Организация.* 			КАК Организация,
	|	ВложенныйКорректировки.ОбъектКорректировки.* 	КАК ОбъектКорректировки,
	|	ВложенныйКорректировки.РасшифровкаОбъекта.* 	КАК РасшифровкаОбъекта,
	|	ВложенныйКорректировки.НалоговоеНазначение.* 	         КАК НалоговоеНазначение,
	|	ВложенныйКорректировки.НалоговоеНазначение.ВидДеятельностиНДС.* 	         КАК ВидДеятельностиНДС,
	|	ВложенныйКорректировки.НалоговоеНазначение.ВидНалоговойДеятельности.* 	     КАК ВидНалоговойДеятельности,
	|	ВложенныйКорректировки.НалоговоеНазначениеПоФакту.* 	     КАК НалоговоеНазначениеПоФакту,
	|	ВложенныйКорректировки.НалоговоеНазначениеПоФакту.ВидДеятельностиНДС.* 	     КАК ВидДеятельностиНДСПоФакту,
	|	ВложенныйКорректировки.НалоговоеНазначениеПоФакту.ВидНалоговойДеятельности.* КАК ВидНалоговойДеятельностиПоФакту,
	|	ВложенныйКорректировки.Регистратор.* 		КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	| (
	| ВЫБРАТЬ 
	|	""Партии товаров""										КАК ТипОбъекта,
	|	РегистрКорректировки.Номенклатура						КАК ОбъектКорректировки,
	|	РегистрКорректировки.ДокументОприходования				КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.Организация	 					КАК Организация,
	|	РегистрКорректировки.НалоговоеНазначение                КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту		 	КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор						КАК Регистратор,
	|
	|	РегистрКорректировки.НДСКредит                     		КАК НДСКредит,
	|	РегистрКорректировки.НДСКредитПоФакту             		КАК НДСКредитПоФакту,		
	|	РегистрКорректировки.НДСКредитПодтвержденный         	КАК НДСКредитПодтвержденный
	|{ВЫБРАТЬ 
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.Номенклатура.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.ДокументОприходования.* 	КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*				КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	|	РегистрНакопления.КорректировкиПартииТоваровНалоговыйУчет КАК РегистрКорректировки
	|	//СОЕДИНЕНИЯ
	|ГДЕ
	|	РегистрКорректировки.Активность = Истина
	|	И РегистрКорректировки.ВидДвижения = &Расход
	|	И РегистрКорректировки.КодОперации = &ПодтвержденнаяКорректировка
    |	И РегистрКорректировки.Период >= &ДатаНач
    |	И ((&ДатаКон = &ПустаяДата) ИЛИ (РегистрКорректировки.Период <= &ДатаКон))
    |	И (НЕ РегистрКорректировки.НДСКредит = РегистрКорректировки.НДСКредитПодтвержденный)
	|{ГДЕ
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.Номенклатура.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.ДокументОприходования.* 	КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*				КАК Регистратор
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|ОБЪЕДИНИТЬ ВСЕ
	|ВЫБРАТЬ 
	|	""Строительство ОС""									КАК ТипОбъекта,
	|	РегистрКорректировки.ОбъектСтроительства				КАК ОбъектКорректировки,
	|	NULL													КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.Организация		 				КАК Организация,
	|	РегистрКорректировки.НалоговоеНазначение 	 			КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту			КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор						КАК Регистратор,
	|
	|	РегистрКорректировки.НДСКредит                     		КАК НДСКредит,
	|	РегистрКорректировки.НДСКредитПоФакту             		КАК НДСКредитПоФакту,		
	|	РегистрКорректировки.НДСКредитПодтвержденный         	КАК НДСКредитПодтвержденный
	|{ВЫБРАТЬ 
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.ОбъектСтроительства.*		КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*				КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	|	РегистрНакопления.КорректировкиСтроительствоОбъектовОсновныхСредствНалоговыйУчет КАК РегистрКорректировки
	|	//СОЕДИНЕНИЯ
	|ГДЕ
	|	РегистрКорректировки.Активность = Истина
	|	И РегистрКорректировки.ВидДвижения = &Расход
	|	И РегистрКорректировки.КодОперации = &ПодтвержденнаяКорректировка
    |	И РегистрКорректировки.Период >= &ДатаНач
    |	И ((&ДатаКон = &ПустаяДата) ИЛИ (РегистрКорректировки.Период <= &ДатаКон))
    |	И (НЕ РегистрКорректировки.НДСКредит = РегистрКорректировки.НДСКредитПодтвержденный)
	|{ГДЕ
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.ОбъектСтроительства.*		КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*				КАК Регистратор
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|ОБЪЕДИНИТЬ ВСЕ
	| ВЫБРАТЬ 
	|	""Незавершенное производство""							КАК ТипОбъекта,
	|	РегистрКорректировки.СтатьяЗатрат						КАК ОбъектКорректировки,
	|	РегистрКорректировки.Затрата							КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.Организация	 					КАК Организация,
	|	РегистрКорректировки.НалоговоеНазначение 				КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту	 		КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор						КАК Регистратор,
	|
	|	РегистрКорректировки.НДСКредит                     		КАК НДСКредит,
	|	РегистрКорректировки.НДСКредитПоФакту             		КАК НДСКредитПоФакту,		
	|	РегистрКорректировки.НДСКредитПодтвержденный         	КАК НДСКредитПодтвержденный
	|{ВЫБРАТЬ 
	|	РегистрКорректировки.Организация.* 					КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*					КАК ОбъектКорректировки,
	|	РегистрКорректировки.Затрата.* 						КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.НалоговоеНазначение.* 			КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* 	КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*					КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	|	РегистрНакопления.КорректировкиНезавершенноеПроизводствоНалоговыйУчет КАК РегистрКорректировки
	|	//СОЕДИНЕНИЯ
	|ГДЕ
	|	РегистрКорректировки.Активность = Истина
	|	И РегистрКорректировки.ВидДвижения = &Расход
	|	И РегистрКорректировки.КодОперации = &ПодтвержденнаяКорректировка
    |	И РегистрКорректировки.Период >= &ДатаНач
    |	И ((&ДатаКон = &ПустаяДата) ИЛИ (РегистрКорректировки.Период <= &ДатаКон))
    |	И (НЕ РегистрКорректировки.НДСКредит = РегистрКорректировки.НДСКредитПодтвержденный)
	|{ГДЕ
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.Затрата.* 					КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*					КАК Регистратор
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|ОБЪЕДИНИТЬ ВСЕ
	| ВЫБРАТЬ 
	|	""Затраты""												КАК ТипОбъекта,
	|	РегистрКорректировки.СтатьяЗатрат						КАК ОбъектКорректировки,
	|	NULL													КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.Организация	 					КАК Организация,
	|	РегистрКорректировки.НалоговоеНазначение	 			КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту	 		КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор						КАК Регистратор,
	|
	|	РегистрКорректировки.НДСКредит                     		КАК НДСКредит,
	|	РегистрКорректировки.НДСКредитПоФакту             		КАК НДСКредитПоФакту,		
	|	РегистрКорректировки.НДСКредитПодтвержденный         	КАК НДСКредитПодтвержденный
	|{ВЫБРАТЬ 
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*					КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	|	РегистрНакопления.КорректировкиЗатратыНалоговыйУчет КАК РегистрКорректировки
	|	//СОЕДИНЕНИЯ
	|ГДЕ
	|	РегистрКорректировки.Активность = Истина
	|	И РегистрКорректировки.ВидДвижения = &Расход
	|	И РегистрКорректировки.КодОперации = &ПодтвержденнаяКорректировка
    |	И РегистрКорректировки.Период >= &ДатаНач
    |	И ((&ДатаКон = &ПустаяДата) ИЛИ (РегистрКорректировки.Период <= &ДатаКон))
    |	И (НЕ РегистрКорректировки.НДСКредит = РегистрКорректировки.НДСКредитПодтвержденный)
	|{ГДЕ
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*					КАК Регистратор
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|ОБЪЕДИНИТЬ ВСЕ
	| ВЫБРАТЬ 
	|	""Брак в производстве""									КАК ТипОбъекта,
	|	РегистрКорректировки.СтатьяЗатрат						КАК ОбъектКорректировки,
	|	NULL													КАК РасшифровкаОбъекта,
	|	РегистрКорректировки.Организация	 					КАК Организация,
	|	РегистрКорректировки.НалоговоеНазначение		 	    КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту	 		КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор						КАК Регистратор,
	|
	|	РегистрКорректировки.НДСКредит                     		КАК НДСКредит,
	|	РегистрКорректировки.НДСКредитПоФакту             		КАК НДСКредитПоФакту,		
	|	РегистрКорректировки.НДСКредитПодтвержденный         	КАК НДСКредитПодтвержденный
	|{ВЫБРАТЬ 
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*					КАК Регистратор
	|	//СВОЙСТВА
	|}
	|ИЗ 
	|	РегистрНакопления.КорректировкиБракВПроизводствеНалоговыйУчет КАК РегистрКорректировки
	|	//СОЕДИНЕНИЯ
	|ГДЕ
	|	РегистрКорректировки.Активность = Истина
	|	И РегистрКорректировки.ВидДвижения = &Расход
	|	И РегистрКорректировки.КодОперации = &ПодтвержденнаяКорректировка
    |	И РегистрКорректировки.Период >= &ДатаНач
    |	И ((&ДатаКон = &ПустаяДата) ИЛИ (РегистрКорректировки.Период <= &ДатаКон))
    |	И (НЕ РегистрКорректировки.НДСКредит = РегистрКорректировки.НДСКредитПодтвержденный)
	|{ГДЕ
	|	РегистрКорректировки.Организация.* 				КАК Организация,
	|	РегистрКорректировки.СтатьяЗатрат.*				КАК ОбъектКорректировки,
	|	РегистрКорректировки.НалоговоеНазначение.* 		КАК НалоговоеНазначение,
	|	РегистрКорректировки.НалоговоеНазначениеПоФакту.* КАК НалоговоеНазначениеПоФакту,
	|	РегистрКорректировки.Регистратор.*				КАК Регистратор
	|	//СВОЙСТВА
	|	//КАТЕГОРИИ
	|}
	|) КАК ВложенныйКорректировки
	|
	|СГРУППИРОВАТЬ ПО
	|	ВложенныйКорректировки.Организация,
	|	ВложенныйКорректировки.ТипОбъекта,
	|	ВложенныйКорректировки.ОбъектКорректировки
	|	//СГРУППИРОВАТЬПО
	|
	|{УПОРЯДОЧИТЬ ПО
	|	ВложенныйКорректировки.Организация.*,
	|	ВложенныйКорректировки.ОбъектКорректировки.*,
	|	ВложенныйКорректировки.РасшифровкаОбъекта.*,
	|	ВложенныйКорректировки.НалоговоеНазначение.*,
	|	ВложенныйКорректировки.НалоговоеНазначениеПоФакту.*,
	|	ВложенныйКорректировки.Регистратор.*
	|	//СВОЙСТВА
	|}
	|
	|ИТОГИ 
	|	СУММА(НДСКредитПоступление),
	|	СУММА(НДСКредитПоФакту),
	|	СУММА(НДСКредитПодтвержденный),
	|	СУММА(НДСКредитКорректировка)
	|	
	|ПО ОБЩИЕ,
	|	Организация,
	|	ТипОбъекта,
	|	ОбъектКорректировки
	|
	|{ИТОГИ ПО
	|	ВложенныйКорректировки.Организация.*,
	|	ВложенныйКорректировки.ТипОбъекта.*,
	|	ВложенныйКорректировки.ОбъектКорректировки.*,
	|	ВложенныйКорректировки.РасшифровкаОбъекта.*,
	|	ВложенныйКорректировки.НалоговоеНазначение.*,
	|	ВложенныйКорректировки.НалоговоеНазначениеПоФакту.*,
	|	ВложенныйКорректировки.Регистратор.*
	|	//СВОЙСТВА
	|}
	|";
	
	СтруктураПредставлениеПолей = Новый Структура(
	"ОбъектКорректировки,
	|Организация,
	|НалоговоеНазначение,
	|ВидДеятельностиНДС,
	|ВидНалоговойДеятельности,
	|НалоговоеНазначениеПоФакту,
	|ВидДеятельностиНДСПоФакту,
	|ВидНалоговойДеятельностиПоФакту,
	|РасшифровкаОбъекта,
	|ТипОбъекта,
	|Регистратор",
	"Объект корректировки",
	"Организация",
	"Налоговое назначение",
	"Вид деятельности НДС",
	"Вид налоговой деятельности",
	"Налоговое назначение по факту",
	"Вид деятельности НДС по факту",
	"Вид налоговой деятельности по факту",
	"Расшифровка объекта корректировки",
	"Тип объекта корректировки",
	"Регистратор (документ движения)");
	
	МассивОтбора = Новый Массив;
	
	ПостроительОтчета.Текст = Текст;
	
	Если ОбщийОтчет.Показатели.Найти("НДСКредитПоступление", "Имя") = Неопределено Тогда
		ОбщийОтчет.ЗаполнитьПоказатели("НДСКредитПоступление", "Сумма н/к при поступлении", истина, "ЧЦ=15; ЧДЦ=2");
	КонецЕсли;
	Если ОбщийОтчет.Показатели.Найти("НДСКредитПоФакту", "Имя") = Неопределено Тогда
		ОбщийОтчет.ЗаполнитьПоказатели("НДСКредитПоФакту", "Сумма н/к при использовании", ложь, "ЧЦ=15; ЧДЦ=2");
	КонецЕсли;
	Если ОбщийОтчет.Показатели.Найти("НДСКредитПодтвержденный", "Имя") = Неопределено Тогда
		ОбщийОтчет.ЗаполнитьПоказатели("НДСКредитПодтвержденный", "Сумма н/к подтвержденная", истина, "ЧЦ=15; ЧДЦ=2");
	КонецЕсли;
	Если ОбщийОтчет.Показатели.Найти("НДСКредитКорректировка", "Имя") = Неопределено Тогда
		ОбщийОтчет.ЗаполнитьПоказатели("НДСКредитКорректировка", "Сумма корректировки н/к", истина, "ЧЦ=15; ЧДЦ=2");
	КонецЕсли;
	
	
	ОбщийОтчет.мНазваниеОтчета = "Корректировки налогового кредита НДС по использованию";
	
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(СтруктураПредставлениеПолей, ПостроительОтчета);
	УправлениеОтчетами.ОчиститьДополнительныеПоляПостроителя(ПостроительОтчета);
	УправлениеОтчетами.ЗаполнитьОтбор(МассивОтбора, ПостроительОтчета);
	ОбщийОтчет.мВыбиратьИмяРегистра = Ложь;
	
	ОбщийОтчет.ВыводитьПоказателиВСтроку = Истина;
	ОбщийОтчет.РаскрашиватьИзмерения = Истина;
	
КонецПроцедуры

Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь) Экспорт
	
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить("Расход",      			ВидДвиженияНакопления.Расход);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить("ПустаяДата",      		ОбщегоНазначения.ПустоеЗначениеТипа(Тип("Дата")));
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить("ПодтвержденнаяКорректировка",  Перечисления.КодыОперацийКорректировкиИспользованияНалоговыйУчет.ПризнаннаяКорректировкаНалоговогоКредита);
	
	ОбщийОтчет.СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок);

КонецПРоцедуры

// Читает свойство Построитель отчета
//
// Параметры
//	Нет
//
Функция ПолучитьПостроительОтчета() Экспорт

	Возврат ОбщийОтчет.ПолучитьПостроительОтчета();

КонецФункции // ПолучитьПостроительОтчета()

// Настраивает отчет по переданной структуре параметров
//
// Параметры:
//	Нет.
//
Процедура Настроить(Параметры) Экспорт

	ОбщийОтчет.Настроить(Параметры, ЭтотОбъект);

КонецПроцедуры

// Возвращает основную форму отчета, связанную с данным экземпляром отчета
//
// Параметры
//	Нет
//
Функция ПолучитьОсновнуюФорму() Экспорт
	
	ОснФорма = ПолучитьФорму();
	ОснФорма.ОбщийОтчет = ОбщийОтчет;
	ОснФорма.ЭтотОтчет = ЭтотОбъект;
	Возврат ОснФорма;
	
КонецФункции // ПолучитьОсновнуюФорму()

// Формирует структуру, в которую складываются настройки
//
Функция СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок) Экспорт
	
	СтруктураНастроек = Новый Структура;
	
	ОбщийОтчет.СформироватьСтруктуруДляСохраненияНастроек(СтруктураНастроек, ПоказыватьЗаголовок);
	
	Возврат СтруктураНастроек;

	
КонецФункции


// Заполняет настройки из структуры - кроме состояния панели "Отбор"
//
Процедура ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки, ПоказыватьЗаголовок, Отчет=Неопределено) Экспорт
		
	// Если отчет, вызвавший порцедуру, не передан, то считаем, что ее вызвал этот отчет
	Если Отчет = Неопределено Тогда
		Отчет = ЭтотОбъект;
	КонецЕсли;

	ОбщийОтчет.ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки, ПоказыватьЗаголовок, Отчет);
	
КонецПроцедуры

#КонецЕсли