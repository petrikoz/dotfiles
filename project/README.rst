Конфиг для рабочих проектов
===========================

Usage
-----

* Создаём дерево каталогов:

    .. code-block:: shell

        mkdir -p /project/folder
        cd /project/folder
        mkdir src tmp

  * ``src`` - здесь лежит исходный код проекта.
  * ``tmp`` - десь лежат различные вспомогательные файлы: образа баз данных, файлы с данными для парсинга / загрузки / выгрузки скриптами и т.п.
* Копируем нужные файлы в нужной форме:
    * ``docker-compose.yml`` - файл настроек для `Docker Compose`_.
        .. warning:: Перед запуском требуются изменения внутри файла.
    * ``Dockerfile`` - образ для запуска проекта с помощью `Docker`_.
        .. warning:: Перед запуском требуются изменения внутри файла.
    * ``editorconfig`` -> ``/project/folder/.editorconfig`` - файл настроек для плагина EditorConfig_.
    * ``fabfile.py`` - файл настроек для `Fabric (fork)`_.
        .. warning:: Перед запуском требуются изменения внутри файла.
    * ``sublime-project`` -> ``/project/folder/project.sublime-project`` - файл настроек для `Sublime Text`_

.. _`Docker Compose`: https://docs.docker.com/compose
.. _`Docker`: https://docs.docker.com
.. _`Fabric (fork)`: https://github.com/mathiasertl/fabric
.. _`Sublime Text`: http://www.sublimetext.com
.. _EditorConfig: http://EditorConfig.org

