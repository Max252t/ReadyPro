import 'ui_models.dart';

class UiMockData {
  static const users = <UiUser>[
    UiUser(
      id: '1',
      email: 'organizer@event.com',
      name: 'Алексей Иванов',
      role: UiRole.organizer,
    ),
    UiUser(
      id: '2',
      email: 'curator1@event.com',
      name: 'Мария Петрова',
      role: UiRole.curator,
    ),
    UiUser(
      id: '3',
      email: 'curator2@event.com',
      name: 'Дмитрий Сидоров',
      role: UiRole.curator,
    ),
    UiUser(
      id: '4',
      email: 'speaker1@event.com',
      name: 'Анна Козлова',
      role: UiRole.speaker,
    ),
    UiUser(
      id: '5',
      email: 'speaker2@event.com',
      name: 'Павел Новиков',
      role: UiRole.speaker,
    ),
    UiUser(
      id: '6',
      email: 'speaker3@event.com',
      name: 'Елена Смирнова',
      role: UiRole.speaker,
    ),
    UiUser(
      id: '7',
      email: 'participant1@event.com',
      name: 'Иван Волков',
      role: UiRole.participant,
    ),
    UiUser(
      id: '8',
      email: 'participant2@event.com',
      name: 'Ольга Морозова',
      role: UiRole.participant,
    ),
  ];

  static UiUser userForRole(UiRole role) =>
      users.firstWhere((u) => u.role == role);

  static final events = <UiEvent>[
    UiEvent(
      id: 'evt1',
      name: 'Технологический хакатон 2026',
      description: 'Трехдневный хакатон по разработке инновационных решений',
      startDate: DateTime(2026, 4, 10),
      endDate: DateTime(2026, 4, 12),
    ),
  ];

  static const sections = <UiSection>[
    UiSection(
      id: 'sec1',
      eventId: 'evt1',
      name: 'Искусственный интеллект',
      description: 'Секция посвященная ИИ и машинному обучению',
      curatorId: '2',
      room: 'Зал А',
    ),
    UiSection(
      id: 'sec2',
      eventId: 'evt1',
      name: 'Блокчейн и Web3',
      description: 'Секция о децентрализованных технологиях',
      curatorId: '3',
      room: 'Зал Б',
    ),
    UiSection(
      id: 'sec3',
      eventId: 'evt1',
      name: 'Кибербезопасность',
      description: 'Секция о защите информации',
      room: 'Зал В',
    ),
  ];

  static final talks = <UiTalk>[
    UiTalk(
      id: 'talk1',
      sectionId: 'sec1',
      speakerId: '4',
      title: 'Введение в нейронные сети',
      description: 'Базовые концепции и практическое применение',
      startTime: DateTime(2026, 4, 10, 10, 0),
      durationMin: 60,
      room: 'Зал А',
      status: UiTalkStatus.ready,
    ),
    UiTalk(
      id: 'talk2',
      sectionId: 'sec1',
      speakerId: '5',
      title: 'LLM модели в производстве',
      description: 'Опыт внедрения больших языковых моделей',
      startTime: DateTime(2026, 4, 10, 11, 30),
      durationMin: 45,
      room: 'Зал А',
      status: UiTalkStatus.draft,
    ),
    UiTalk(
      id: 'talk3',
      sectionId: 'sec2',
      speakerId: '6',
      title: 'Смарт-контракты на практике',
      description: 'Разработка и деплой умных контрактов',
      startTime: DateTime(2026, 4, 10, 10, 0),
      durationMin: 90,
      room: 'Зал Б',
      status: UiTalkStatus.ready,
    ),
    UiTalk(
      id: 'talk4',
      sectionId: 'sec2',
      speakerId: '4',
      title: 'DeFi экосистема',
      description: 'Обзор децентрализованных финансов',
      startTime: DateTime(2026, 4, 10, 14, 0),
      durationMin: 60,
      room: 'Зал Б',
      status: UiTalkStatus.ready,
    ),
  ];

  static final tasks = <UiTask>[
    UiTask(
      id: 'task1',
      eventId: 'evt1',
      assignedTo: '2',
      createdBy: '1',
      title: 'Проверить презентации спикеров',
      description: 'Убедиться что все презентации загружены',
      completed: true,
      dueDate: DateTime(2026, 4, 8),
    ),
    UiTask(
      id: 'task2',
      eventId: 'evt1',
      assignedTo: '2',
      createdBy: '1',
      title: 'Подготовить раздаточный материал',
      description: 'Распечатать программу секции для участников',
      completed: false,
      dueDate: DateTime(2026, 4, 9),
    ),
    UiTask(
      id: 'task3',
      eventId: 'evt1',
      assignedTo: '4',
      createdBy: '1',
      title: 'Отправить презентацию',
      description: 'Загрузить финальную версию презентации',
      completed: false,
      dueDate: DateTime(2026, 4, 9),
    ),
    UiTask(
      id: 'task4',
      eventId: 'evt1',
      assignedTo: '3',
      createdBy: '1',
      title: 'Проверить оборудование в зале',
      description: 'Убедиться что проектор и микрофоны работают',
      completed: false,
      dueDate: DateTime(2026, 4, 9),
    ),
  ];

  static final schedule = <UiScheduleEntry>[
    UiScheduleEntry(
      id: 'sch1',
      userId: '7',
      talkId: 'talk1',
      createdAt: DateTime(2026, 3, 15, 10, 0),
    ),
    UiScheduleEntry(
      id: 'sch2',
      userId: '7',
      talkId: 'talk3',
      createdAt: DateTime(2026, 3, 15, 10, 5),
    ),
    UiScheduleEntry(
      id: 'sch3',
      userId: '8',
      talkId: 'talk1',
      createdAt: DateTime(2026, 3, 16, 14, 0),
    ),
    UiScheduleEntry(
      id: 'sch4',
      userId: '8',
      talkId: 'talk4',
      createdAt: DateTime(2026, 3, 16, 14, 5),
    ),
  ];

  static final feedback = <UiFeedback>[
    UiFeedback(
      id: 'fb1',
      talkId: 'talk1',
      userId: '7',
      rating: 5,
      comment:
          'Отличный доклад! Очень понятно объяснили сложные концепции',
      createdAt: DateTime(2026, 4, 10, 11, 0),
    ),
    UiFeedback(
      id: 'fb2',
      talkId: 'talk3',
      userId: '7',
      rating: 4,
      comment: 'Интересно, но хотелось бы больше примеров кода',
      createdAt: DateTime(2026, 4, 10, 11, 30),
    ),
  ];

  static final comments = <UiComment>[
    UiComment(
      id: 'cmt1',
      talkId: 'talk1',
      userId: '7',
      message: 'Какие фреймворки вы рекомендуете для начинающих?',
      createdAt: DateTime(2026, 4, 10, 10, 30),
    ),
    UiComment(
      id: 'cmt2',
      talkId: 'talk1',
      userId: '4',
      message: 'Я бы посоветовал начать с PyTorch или TensorFlow',
      createdAt: DateTime(2026, 4, 10, 10, 32),
      replyTo: 'cmt1',
    ),
    UiComment(
      id: 'cmt3',
      talkId: 'talk1',
      userId: '8',
      message: 'Можете посоветовать литературу по теме?',
      createdAt: DateTime(2026, 4, 10, 10, 45),
    ),
  ];

  static final reports = <UiCuratorReport>[
    UiCuratorReport(
      id: 'rep1',
      sectionId: 'sec1',
      curatorId: '2',
      reportText:
          'Секция прошла успешно. Все доклады начались вовремя. Участники активно задавали вопросы.',
      createdAt: DateTime(2026, 4, 10, 18, 0),
    ),
  ];
}

