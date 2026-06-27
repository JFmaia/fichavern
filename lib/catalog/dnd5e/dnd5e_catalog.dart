import 'package:fichavern/domain/domain.dart';

/// Catálogo mínimo de D&D 5e escrito à mão.
/// Serve de especificação de referência para o futuro pipeline de IA (M8+).
/// Convenção de idioma: chaves e ids técnicos em inglês; name/summary/whyItMatters em português.
const List<CatalogOption> dnd5eCatalog = [
  ..._races,
  ..._classes,
];

// ─── Raças ───────────────────────────────────────────────────────────────────

const _races = [
  CatalogOption(
    id: 'dnd5e.race.dwarf',
    systemId: 'dnd5e',
    step: 'race',
    name: 'Anão',
    description:
        'Os anões são conhecidos pela determinação, pelo trabalho duro e pela lealdade ao clã.',
    summary: 'Robusto, vê no escuro, resiste a veneno.',
    whyItMatters:
        'O bônus de Constituição aumenta seus PV e resistências. Ótima escolha para quem quer ficar na linha de frente.',
    tags: ['resistente', 'visão no escuro', 'tradicional'],
    unlocks: [],
    prerequisites: [],
    effects: [
      AbilityBonusEffect(ability: 'constitution', value: 2),
      SetSpeedEffect(value: 25),
      GrantsTraitEffect(ref: 'dnd5e.trait.darkvision'),
      GrantsTraitEffect(ref: 'dnd5e.trait.dwarven_resilience'),
    ],
  ),
  CatalogOption(
    id: 'dnd5e.race.elf',
    systemId: 'dnd5e',
    step: 'race',
    name: 'Elfo',
    description:
        'Os elfos são um povo de graça sublime, imbuído de magia e ligado à natureza.',
    summary: 'Ágil, vê no escuro, sentidos aguçados.',
    whyItMatters:
        'O bônus de Destreza melhora CA, Furtividade e ataques à distância. Ideal para classes que preferem velocidade a força bruta.',
    tags: ['ágil', 'visão no escuro', 'mágico'],
    unlocks: [],
    prerequisites: [],
    effects: [
      AbilityBonusEffect(ability: 'dexterity', value: 2),
      SetSpeedEffect(value: 30),
      GrantsTraitEffect(ref: 'dnd5e.trait.darkvision'),
      GrantsTraitEffect(ref: 'dnd5e.trait.fey_ancestry'),
      GrantsProficiencyEffect(ref: 'dnd5e.skill.perception'),
    ],
  ),
];

// ─── Classes ─────────────────────────────────────────────────────────────────

const _classes = [
  CatalogOption(
    id: 'dnd5e.class.fighter',
    systemId: 'dnd5e',
    step: 'class',
    name: 'Guerreiro',
    description:
        'Guerreiros dominam armas e armaduras, e possuem conhecimento profundo das habilidades de combate.',
    summary: 'Alto PV, todas as armaduras e armas, estilo de combate único.',
    whyItMatters:
        'A escolha mais simples e mais durável para o combate. Fácil de aprender, difícil de derrubar.',
    tags: ['combate', 'resistente', 'versátil'],
    unlocks: [],
    prerequisites: [],
    effects: [
      SetHpEffect(perLevel: 10),
      GrantsProficiencyEffect(ref: 'dnd5e.armor.light'),
      GrantsProficiencyEffect(ref: 'dnd5e.armor.medium'),
      GrantsProficiencyEffect(ref: 'dnd5e.armor.heavy'),
      GrantsProficiencyEffect(ref: 'dnd5e.armor.shields'),
      GrantsProficiencyEffect(ref: 'dnd5e.weapon_group.simple'),
      GrantsProficiencyEffect(ref: 'dnd5e.weapon_group.martial'),
    ],
  ),
  CatalogOption(
    id: 'dnd5e.class.wizard',
    systemId: 'dnd5e',
    step: 'class',
    name: 'Mago',
    description:
        'Os magos são usuários supremos da magia arcana, definidos pelas magias que conjuram.',
    summary: 'Magias poderosas, baixo PV, acesso ao Livro de Magias.',
    whyItMatters:
        'Potencial de controle e dano incomparável à distância. Requer proteção, mas pode mudar o rumo de batalhas inteiras.',
    tags: ['magia', 'inteligência', 'suporte'],
    unlocks: [],
    prerequisites: [],
    effects: [
      SetHpEffect(perLevel: 6),
      GrantsProficiencyEffect(ref: 'dnd5e.weapon_group.simple'),
    ],
  ),
];
