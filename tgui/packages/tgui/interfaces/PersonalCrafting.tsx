import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import {
  Divider,
  Button,
  Section,
  Tabs,
  Stack,
  Box,
  Input,
  Icon,
  Tooltip,
  NoticeBox,
} from '../components';
import { Window } from '../layouts';
import { Food } from './PreferencesMenu/data';

const TYPE_ICONS = {
  'Can Make': 'utensils',
  [Food.Alcohol]: 'wine-glass',
  [Food.Breakfast]: 'sun',
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'fire',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'wheat-awn',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'bacon',
  [Food.Nuts]: 'seedling',
  [Food.Oranges]: 'apple-alt',
  [Food.Pineapple]: 'apple-alt',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
} as const;

const CATEGORY_ICONS_CRAFTING = {
  'Can Make': 'hammer',
  'Weapons Melee': 'hand-fist',
  'Weapons Ranged': 'gun',
  'Weapon Ammo': 'box',
  Robotics: 'robot',
  Misc: 'shapes',
  Tribal: 'campground',
  Clothing: 'shirt',
  Drinks: 'wine-bottle',
  Chemistry: 'microscope',
  Atmospherics: 'fan',
  Structures: 'cube',
  Tiles: 'border-all',
  Windows: 'person-through-window',
  Doors: 'door-open',
  Furniture: 'chair',
  Equipment: 'calculator',
  Containers: 'briefcase',
  Tools: 'screwdriver-wrench',
  Entertainment: 'masks-theater',
  'Blood Cult': 'users',
} as const;

const CATEGORY_ICONS_COOKING = {
  'Can Make': 'utensils',
  Breads: 'bread-slice',
  Burgers: 'burger',
  Cakes: 'cake-candles',
  'Egg-Based Food': 'egg',
  Frozen: 'ice-cream',
  'Lizard Food': 'dragon',
  Meats: 'bacon',
  'Mexican Food': 'pepper-hot',
  'Misc. Food': 'shapes',
  'Mothic Food': 'shirt',
  Pastries: 'cookie',
  Pies: 'chart-pie',
  Pizzas: 'pizza-slice',
  Salads: 'leaf',
  Sandwiches: 'hotdog',
  Seafood: 'fish',
  Soups: 'mug-hot',
  Spaghettis: 'wheat-awn',
} as const;

enum MODE {
  crafting,
  cooking,
}

enum TABS {
  category,
  material,
  foodtype,
}

type AtomData = {
  name: string;
  is_reagent: BooleanLike;
};

type Atoms = {
  [key: number]: number;
};

type Material = {
  atom_id: string;
  occurences: number;
};

type Recipe = {
  ref: string;
  result: number;
  name: string;
  desc: string;
  category: string;
  non_craftable: BooleanLike;
  is_reaction: BooleanLike;
  reqs: Atoms;
  chem_catalysts: Atoms;
  tool_behaviors: string[];
  tool_paths: string[];
  machinery: string[];
  structures: string[];
  steps: string[];
  foodtypes: string[];
};

type Diet = {
  liked_food: string[];
  disliked_food: string[];
  toxic_food: string[];
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  mode: BooleanLike;
  forced_mode: BooleanLike;
  display_compact: BooleanLike;
  display_craftable_only: BooleanLike;
  craftability: Record<string, BooleanLike>;
  // Static
  diet: Diet;
  atom_data: AtomData[];
  recipes: Recipe[];
  categories: string[];
  material_occurences: Material[];
  foodtypes: string[];
  nutriments: number;
};

interface Item {
  name: string;
  desc?: string;
  reqs?: Record<string, number>;
  chem_catalysts?: Record<string, number>;
  tool_paths?: string[];
  tool_behaviors?: string[];
  machinery?: string[];
  structures?: string[];
  steps?: string[];
  result: string;
  non_craftable?: boolean;
  nutriments?: number;
  foodtypes?: string[];
  ref: string;
}

interface RecipeContentProps {
  item: Item;
  craftable: boolean;
  busy: boolean;
  mode: any;
  diet: any;
}

export const PersonalCrafting = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
  } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [pages, setPages] = useLocalState('pages', 1);
  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];
  const [activeCategory, setCategory] = useLocalState<string>(
    'category',
    Object.keys(craftability).length
      ? 'Can Make'
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING,
  );
  const [activeType, setFoodType] = useLocalState(
    'foodtype',
    Object.keys(craftability).length ? 'Can Make' : data.foodtypes[0],
  );
  const material_occurences = flow([
    sortBy<Material>((material) => -material.occurences),
  ])(data.material_occurences);
  const [activeMaterial, setMaterial] = useLocalState(
    'material',
    material_occurences[0].atom_id,
  );
  const [tabMode, setTabMode] = useLocalState('tabMode', 0);
  const searchName = createSearch(searchText, (item: Recipe) => item.name);
  let recipes = flow([
    filter<Recipe>(
      (recipe) =>
        // If craftable only is selected, then filter by craftability
        (!display_craftable_only || Boolean(craftability[recipe.ref])) &&
        // Ignore categories and types when searching
        (searchText.length > 0 ||
          // Is foodtype mode and the active type matches
          (tabMode === TABS.foodtype &&
            mode === MODE.cooking &&
            ((activeType === 'Can Make' && Boolean(craftability[recipe.ref])) ||
              recipe.foodtypes?.includes(activeType))) ||
          // Is material mode and the active material or catalysts match
          (tabMode === TABS.material &&
            recipe.reqs &&
            Object.keys(recipe.reqs).includes(activeMaterial)) ||
          // Or with Optional Chaining
          // (tabMode === TABS.material && Object.keys(recipe.reqs ?? {}).includes(activeMaterial)) ||
          // Is category mode and the active category matches
          (tabMode === TABS.category &&
            ((activeCategory === 'Can Make' &&
              Boolean(craftability[recipe.ref])) ||
              recipe.category === activeCategory))),
    ),
    sortBy<Recipe>((recipe) => [
      -Number(craftability[recipe.ref]),
      recipe.name.toLowerCase(),
    ]),
  ])(data.recipes);
  if (searchText.length > 0) {
    recipes = recipes.filter(searchName);
  }
  const canMake = ['Can Make'];
  const categories = canMake
    .concat(data.categories.sort())
    .filter((i) => (i === 'Weaponry' ? true : i));
  const foodtypes = canMake.concat(data.foodtypes.sort());
  const pageSize =
    searchText.length > 0
      ? display_compact
        ? 20
        : 10
      : display_compact
        ? 60
        : 30;
  const displayLimit = pageSize * pages;
  const content = document.getElementById('content');
  const CATEGORY_ICONS =
    mode === MODE.cooking ? CATEGORY_ICONS_COOKING : CATEGORY_ICONS_CRAFTING;
  return (
    <Window width={700} height={720}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'200px'}>
            <Section fill>
              <Stack fill vertical justify={'space-between'}>
                <Stack.Item>
                  <Input
                    autoFocus
                    placeholder={
                      'Search in ' +
                      data.recipes.length +
                      (mode === MODE.cooking ? ' recipes...' : ' designs...')
                    }
                    value={searchText}
                    onInput={(e, value) => {
                      setPages(1);
                      setSearchText(value);
                    }}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Tabs fluid textAlign="center">
                    <Tabs.Tab
                      selected={tabMode === TABS.category}
                      onClick={() => {
                        if (tabMode === TABS.category) {
                          return;
                        }
                        setTabMode(TABS.category);
                        setPages(1);
                        setCategory(
                          Object.keys(craftability).length
                            ? 'Can Make'
                            : data.categories[0],
                        );
                      }}
                    >
                      Category
                    </Tabs.Tab>
                    {mode === MODE.cooking && (
                      <Tabs.Tab
                        selected={tabMode === TABS.foodtype}
                        onClick={() => {
                          if (tabMode === TABS.foodtype) {
                            return;
                          }
                          setTabMode(TABS.foodtype);
                          setPages(1);
                          setFoodType(
                            Object.keys(craftability).length
                              ? 'Can Make'
                              : data.foodtypes[0],
                          );
                        }}
                      >
                        Type
                      </Tabs.Tab>
                    )}
                    <Tabs.Tab
                      selected={tabMode === TABS.material}
                      onClick={() => {
                        if (tabMode === TABS.material) {
                          return;
                        }
                        setTabMode(TABS.material);
                        setPages(1);
                        setMaterial(material_occurences[0].atom_id);
                      }}
                    >
                      {mode === MODE.cooking ? 'Ingredient' : 'Material'}
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
                <Stack.Item grow m={-1} style={{ 'overflow-y': 'auto' }}>
                  <Box height={'100%'} p={1}>
                    <Tabs vertical>
                      {tabMode === TABS.foodtype &&
                        mode === MODE.cooking &&
                        foodtypes.map((foodtype) => (
                          <Tabs.Tab
                            key={foodtype}
                            selected={
                              activeType === foodtype && searchText.length === 0
                            }
                            onClick={(e) => {
                              setFoodType(foodtype);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <FoodtypeContent
                              type={foodtype}
                              diet={diet}
                              craftableCount={Object.keys(craftability).length}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.material &&
                        material_occurences.map((material) => (
                          <Tabs.Tab
                            key={material.atom_id}
                            selected={
                              activeMaterial === material.atom_id &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setMaterial(material.atom_id);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <MaterialContent
                              atom_id={material.atom_id}
                              occurences={material.occurences}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.category &&
                        categories.map((category) => (
                          <Tabs.Tab
                            key={category}
                            selected={
                              activeCategory === category &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setCategory(category);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <Stack>
                              <Stack.Item width="14px" textAlign="center">
                                <Icon
                                  color={
                                    category === 'Blood Cult'
                                      ? 'red'
                                      : 'default'
                                  }
                                  name={CATEGORY_ICONS[category] || 'circle'}
                                />
                              </Stack.Item>
                              <Stack.Item
                                grow
                                color={
                                  category === 'Blood Cult' ? 'red' : 'default'
                                }
                              >
                                {category}
                              </Stack.Item>
                              {category === 'Can Make' && (
                                <Stack.Item>
                                  {Object.keys(craftability).length}
                                </Stack.Item>
                              )}
                            </Stack>
                          </Tabs.Tab>
                        ))}
                    </Tabs>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Divider />
                  <Button.Checkbox
                    fluid
                    content="Can make only"
                    checked={display_craftable_only}
                    onClick={() => {
                      act('toggle_recipes');
                    }}
                  />
                  <Button.Checkbox
                    fluid
                    content="Compact list"
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  />
                </Stack.Item>
                {!forced_mode && (
                  <Stack.Item>
                    <Stack textAlign="center">
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          content="Craft"
                          checked={mode === MODE.crafting}
                          icon="hammer"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.crafting ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.crafting) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_CRAFTING);
                            act('toggle_mode');
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          content="Cook"
                          checked={mode === MODE.cooking}
                          icon="utensils"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.cooking ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.cooking) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_COOKING);
                            act('toggle_mode');
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow my={-1}>
            <Box
              id="content"
              height={'100%'}
              pr={1}
              pt={1}
              mr={-1}
              style={{ 'overflow-y': 'auto' }}
            >
              {recipes.length > 0 ? (
                recipes
                  .slice(0, displayLimit)
                  .map((item) =>
                    display_compact ? (
                      <RecipeContentCompact
                        key={item.ref}
                        item={item}
                        craftable={
                          !item.non_craftable && Boolean(craftability[item.ref])
                        }
                        busy={busy}
                        mode={mode}
                      />
                    ) : (
                      <RecipeContent
                        key={item.ref}
                        item={item}
                        craftable={
                          !item.non_craftable && Boolean(craftability[item.ref])
                        }
                        busy={busy}
                        mode={mode}
                        diet={diet}
                      />
                    ),
                  )
              ) : (
                <NoticeBox m={1} p={1}>
                  No recipes found.
                </NoticeBox>
              )}
              {recipes.length > displayLimit && (
                <Section
                  mb={2}
                  textAlign="center"
                  style={{ cursor: 'pointer' }}
                  onClick={() => setPages(pages + 1)}
                >
                  Load {Math.min(pageSize, recipes.length - displayLimit)}{' '}
                  more...
                </Section>
              )}
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MaterialContent = (props) => {
  const { atom_id, occurences } = props;
  const { data } = useBackend<Data>();
  const name = data.atom_data[atom_id - 1].name;
  const mode = data.mode;
  return (
    <Stack>
      <Stack.Item>
        <Box
          verticalAlign="middle"
          inline
          ml={-1.5}
          mr={-0.5}
          className={classes([
            mode ? 'cooking32x32' : 'crafting32x32',
            'a' + atom_id,
          ])}
        />
      </Stack.Item>
      <Stack.Item
        height="32px"
        lineHeight="32px"
        grow
        style={{
          'text-transform': 'capitalize',
          overflow: 'hidden',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
        }}
      >
        {name}
      </Stack.Item>
      <Stack.Item height="32px" lineHeight="32px">
        {occurences}
      </Stack.Item>
    </Stack>
  ) as any;
};

const FoodtypeContent = (props) => {
  const { type, diet, craftableCount } = props;
  let iconName = '',
    iconColor = '';

  // We use iconName in the return to see if this went through.
  if (type !== 'Can Make' && diet) {
    if (diet.liked_food.includes(type)) {
      iconName = 'face-laugh-beam';
      iconColor = 'good';
    } else if (diet.disliked_food.includes(type)) {
      iconName = 'face-tired';
      iconColor = 'average';
    } else if (diet.toxic_food.includes(type)) {
      iconName = 'skull-crossbones';
      iconColor = 'bad';
    }
  }

  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={TYPE_ICONS[type] || 'circle'} />
      </Stack.Item>
      <Stack.Item grow style={{ 'text-transform': 'capitalize' }}>
        {type.toLowerCase()}
      </Stack.Item>
      <Stack.Item>
        {type === 'Can Make'
          ? craftableCount
          : iconName && <Icon name={iconName} color={iconColor} />}
      </Stack.Item>
    </Stack>
  );
};

const RecipeContentCompact = ({ item, craftable, busy, mode }) => {
  const { act, data } = useBackend<Data>();

  // Function to handle pushing steps (unchanged)
  const specialSteps = [
    'Optional Steps',
    'End Optional Steps',
    'Exclusive Optional Steps',
    'End Exclusive Optional Steps',
    'Optional Step',
    'End Optional Step',
  ];

  const groupedSteps: string[] = [];
  let previousStep = '';
  let duplicateCount = 0;

  const pushStep = (step: string, count: number) => {
    const stepText = count > 1 ? `${step} x${count}` : step;
    groupedSteps.push(stepText);
  };

  item.steps?.forEach((step) => {
    const trimmedStep = step.trim();
    if (trimmedStep === previousStep) {
      duplicateCount++;
    } else {
      if (duplicateCount > 0) {
        pushStep(previousStep, duplicateCount);
      }
      previousStep = trimmedStep;
      duplicateCount = 1;
    }
  });

  if (duplicateCount > 0) {
    pushStep(previousStep, duplicateCount);
  }

  return (
    <Section>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box
            className={classes([
              mode ? 'cooking32x32' : 'crafting32x32',
              'a' + item.result,
            ])}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ 'text-transform': 'capitalize' }} color={'gray'}>
                {Array.isArray(item.reqs) &&
                  Object.keys(item.reqs).length > 0 &&
                  Object.keys(item.reqs)
                    .map((atom_id) => {
                      const name = data.atom_data?.[(atom_id as any) - 1]?.name;
                      const is_reagent =
                        data.atom_data?.[(atom_id as any) - 1]?.is_reagent;
                      const amount = item.reqs[atom_id];
                      return is_reagent
                        ? `${name}\xa0${amount}u`
                        : amount > 1
                          ? `${name}\xa0${amount}x`
                          : name;
                    })
                    .join(', ')}

                {item.chem_catalysts &&
                  Object.keys(item.chem_catalysts).length > 0 &&
                  ', ' +
                    Object.keys(item.chem_catalysts)
                      .map((atom_id) => {
                        const name =
                          data.atom_data?.[(atom_id as any) - 1]?.name;
                        const is_reagent =
                          data.atom_data?.[(atom_id as any) - 1]?.is_reagent;
                        const amount = item.chem_catalysts[atom_id];
                        return is_reagent
                          ? `${name}\xa0${amount}u`
                          : amount > 1
                            ? `${name}\xa0${amount}x`
                            : name;
                      })
                      .join(', ')}

                {item.tool_paths &&
                  item.tool_paths.length > 0 &&
                  ', ' +
                    item.tool_paths
                      .map((item) => data.atom_data?.[(item as any) - 1]?.name)
                      .join(', ')}

                {item.machinery &&
                  item.machinery.length > 0 &&
                  ', ' +
                    item.machinery
                      .map((item) => data.atom_data?.[(item as any) - 1]?.name)
                      .join(', ')}

                {item.structures &&
                  item.structures.length > 0 &&
                  ', ' +
                    item.structures
                      .map((item) => data.atom_data?.[(item as any) - 1]?.name)
                      .join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!item.non_craftable ? (
                <Box>
                  {!!item.tool_behaviors && (
                    <Tooltip
                      content={'Tools: ' + item.tool_behaviors.join(', ')}
                    >
                      <Icon p={1} name="screwdriver-wrench" />
                    </Tooltip>
                  )}
                  <Button
                    my={0.3}
                    lineHeight={2.5}
                    align="center"
                    content="Make"
                    disabled={!craftable || busy}
                    icon={
                      busy
                        ? 'circle-notch'
                        : mode === MODE.cooking
                          ? 'utensils'
                          : 'hammer'
                    }
                    iconSpin={busy ? 1 : 0}
                    onClick={() =>
                      act('make', {
                        recipe: item.ref,
                      })
                    }
                  />
                </Box>
              ) : (
                item.steps && (
                  <Tooltip
                    content={groupedSteps.map((step, index) => (
                      <Box key={index}>{step}</Box>
                    ))}
                  >
                    <Box fontSize={1.5} p={1}>
                      <Icon name="circle-question-o" />
                    </Box>
                  </Tooltip>
                )
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipeContent = ({ item, craftable, busy, mode, diet }) => {
  const { act } = useBackend<Data>();

  const specialSteps = [
    'Optional Steps',
    'End Optional Steps',
    'Exclusive Optional Steps',
    'End Exclusive Optional Steps',
    'Optional Step',
    'End Optional Step',
  ];

  interface StepGroup {
    label: string;
    steps: string[];
  }

  type GroupedStep = string | StepGroup;

  const isValidGroup = (group: StepGroup | null): group is StepGroup => {
    return group !== null;
  };

  const groupedSteps: string[] = [];
  const groupStack: StepGroup[] = [];
  let currentGroup: StepGroup | null = null;
  let groupKey = 0;

  // Function to push step to groupedSteps or currentGroup
  const pushStep = (step: string, count: number) => {
    const stepText = count > 1 ? `${step} x${count}` : step;
    if (currentGroup) {
      currentGroup.steps.push(stepText);
    } else {
      groupedSteps.push(<li key={groupKey++}>{stepText}</li>);
    }
  };

  let previousStep = '';
  let duplicateCount = 0;

  item.steps?.forEach((step, index) => {
    const trimmedStep = step.trim();

    if (specialSteps.includes(trimmedStep)) {
      // Push previous duplicate steps if any
      if (duplicateCount > 0) {
        pushStep(previousStep, duplicateCount);
        duplicateCount = 0;
      }

      if (trimmedStep.includes('End')) {
        // Close the current group if it exists and has steps
        if (currentGroup) {
          if (currentGroup.steps.length > 0) {
            groupedSteps.push(
              <Box
                key={`group-${groupKey++}`}
                style={{
                  padding: '10px',
                  border: '1px solid gray',
                  margin: '10px 0',
                }}
              >
                <strong>{currentGroup.label}</strong>
                <ul>
                  {currentGroup.steps.map((groupStep, groupIndex) => (
                    <li key={groupIndex}>{groupStep}</li>
                  ))}
                </ul>
              </Box>,
            );
          }
          currentGroup = null; // Reset the group
        }

        // Pop the previous group from the stack
        if (groupStack.length > 0) {
          currentGroup = groupStack.pop() || null;
        }
      } else {
        // Handle starting a new group
        if (currentGroup && currentGroup.steps.length > 0) {
          // If there's an ongoing group, push it to the stack
          groupStack.push(currentGroup);
        }
        // Start a new group
        currentGroup = { label: trimmedStep, steps: [] };
      }
    } else if (trimmedStep === previousStep) {
      duplicateCount++;
    } else {
      // Push previous duplicate steps if any
      if (duplicateCount > 0) {
        pushStep(previousStep, duplicateCount);
      }
      previousStep = trimmedStep;
      duplicateCount = 1;
    }
  });

  // Push the last duplicate steps if any
  if (duplicateCount > 0) {
    pushStep(previousStep, duplicateCount);
  }

  // Handle any leftover group that didn't get closed
  if (currentGroup && (currentGroup as any).steps.length > 0) {
    groupedSteps.push(
      <Box
        key={`leftover-group-${groupKey}`}
        style={{ padding: '10px', border: '1px solid gray', margin: '10px 0' }}
      >
        <strong>{(currentGroup as any).label}</strong>
        <ul>
          {(currentGroup as any).steps.map((groupStep, groupIndex) => (
            <li key={groupIndex}>{groupStep}</li>
          ))}
        </ul>
      </Box>,
    );
  }

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box width={'64px'} height={'64px'} mr={1}>
            <Box
              width={'32px'}
              height={'32px'}
              style={{
                transform: 'scale(2)',
              }}
              m={'16px'}
              className={classes([
                mode ? 'cooking32x32' : 'crafting32x32',
                'a' + item.result,
              ])}
            />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              {item.desc && <Box color={'gray'}>{item.desc}</Box>}
              <Box style={{ 'text-transform': 'capitalize' }}>
                {item.reqs && (
                  <Box>
                    <GroupTitle
                      title={
                        mode === MODE.cooking ? 'Ingredients' : 'Materials'
                      }
                    />
                    {Object.keys(item.reqs).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.reqs[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {item.chem_catalysts && (
                  <Box>
                    <GroupTitle title="Catalysts" />
                    {Object.keys(item.chem_catalysts).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.chem_catalysts[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {(item.tool_paths || item.tool_behaviors) && (
                  <Box>
                    <GroupTitle title="Tools" />
                    {item.tool_paths &&
                      item.tool_paths.map((tool) => (
                        <AtomContent key={tool} atom_id={tool} amount={1} />
                      ))}
                    {item.tool_behaviors &&
                      item.tool_behaviors.map((tool) => (
                        <ToolContent key={tool} tool={tool} />
                      ))}
                  </Box>
                )}
                {item.machinery && (
                  <Box>
                    <GroupTitle title="Machinery" />
                    {item.machinery.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
                {item.structures && (
                  <Box>
                    <GroupTitle title="Structures" />
                    {item.structures.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
              </Box>
              {!!item.steps?.length && (
                <Box>
                  <GroupTitle title="Steps" />
                  <ul>{groupedSteps}</ul>
                </Box>
              )}
            </Stack.Item>
            <Stack.Item pl={1}>
              {!item.non_craftable && (
                <Button
                  width="104px"
                  lineHeight={2.5}
                  align="center"
                  content="Make"
                  disabled={!craftable || busy}
                  icon={
                    busy
                      ? 'circle-notch'
                      : mode === MODE.cooking
                        ? 'utensils'
                        : 'hammer'
                  }
                  iconSpin={busy ? 1 : 0}
                  onClick={() =>
                    act('make', {
                      recipe: item.ref,
                    })
                  }
                />
              )}
              {item.nutriments > 0 && (
                <Box color={'gray'} width={'104px'} lineHeight={1.5} mt={1}>
                  Nutrition: {item.nutriments}
                  <Divider />
                </Box>
              )}
              {item.foodtypes?.length > 0 && (
                <Box color={'gray'} width={'104px'} lineHeight={1.5} mt={1}>
                  {item.foodtypes.map((foodtype) => (
                    <FoodtypeContent
                      key={item.ref}
                      type={foodtype}
                      diet={diet}
                    />
                  ))}
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AtomContent = ({ atom_id, amount }) => {
  const { data } = useBackend<Data>();
  const name = data.atom_data[atom_id - 1]?.name;
  const is_reagent = data.atom_data[atom_id - 1]?.is_reagent;
  const mode = data.mode;
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes([
          mode ? 'cooking32x32' : 'crafting32x32',
          'a' + atom_id,
        ])}
      />
      <Box inline verticalAlign="middle">
        {name}
        {is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  ) as any;
};

const ToolContent = ({ tool }) => {
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes(['crafting32x32', tool])}
      />
      <Box inline verticalAlign="middle">
        {tool}
      </Box>
    </Box>
  ) as any;
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color={'gray'}>{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
