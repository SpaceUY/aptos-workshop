export const CONTRACT_CONFIG = {
  MODULE_ADDRESS: process.env.NEXT_PUBLIC_MODULE_ADDRESS,

  MODULE_NAME: "galactic_packs",

  FUNCTIONS: {
    BUY_PACK: "buy_pack",
    OPEN_PACK: "open_pack",
    GET_TOTAL_SOLD: "get_total_sold",
    GET_PACK_TOKEN_ID: "get_pack_token_id",
  },

  CONSTANTS: {
    PACK_PRICE: 10000000,
    MAX_PACKS: 100,
    PACK_SIZE: 3,
    TOTAL_COLLECTIONS: 4,
  },

  COLLECTIONS: {
    GALACTIC_PACK: 0,
    ALIEN: 1,
    PREDATOR: 2,
    YODA: 3,
  },

  RARITIES: {
    COMMON: 0,
    UNCOMMON: 1,
    RARE: 2,
    EPIC: 3,
    LEGENDARY: 4,
    MYTHIC: 5,
  },

  RARITY_PROBABILITIES: {
    0: 30,
    1: 25,
    2: 20,
    3: 12,
    4: 8,
    5: 5,
  } as Record<number, number>,

  RARITY_NAMES: {
    0: "Common",
    1: "Uncommon",
    2: "Rare",
    3: "Epic",
    4: "Legendary",
    5: "Mythic",
  } as Record<number, string>,

  RARITY_COLORS: {
    0: "gray-400",
    1: "green-400",
    2: "blue-400",
    3: "purple-400",
    4: "orange-400",
    5: "red-400",
  } as Record<number, string>,
};

export const COLLECTION_URIS = {
  GALACTIC_PACK: "ipfs://",
  ALIEN: "ipfs://bafybeidkl6xkucmemtszbc22yx4l2u27msicv3rmdzevxafb3qh3c6kvwi",
  PREDATOR:
    "ipfs://bafybeihtosrbr4vzj7w7ctucmypy2zzqnm2wmdpbk5zdpv2zuvoyq3p7fu",
  YODA: "ipfs://bafybeigdynpadvw7mra7gn6wph24ewxwtdhknhdpjes3on2sfdxfeyajmy",
};

export const COLLECTION_NAMES = {
  GALACTIC_PACK: "Galactic Pack",
  ALIEN: "Alien",
  PREDATOR: "Predator",
  YODA: "Yoda",
};
