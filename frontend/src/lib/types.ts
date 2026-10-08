export type UUID = string;

export type ToolCategory = 'AV' | 'Cleaning' | 'Garden' | 'Outdoor' | 'Site equipment' | 'Tools';

export type Tool = {
    id: UUID;
    name: string;
    description: string;
    photoID: UUID;
    imageUrl: string;
    assetCode: string;
    category: ToolCategory;
    dailyRateCents: number;
    availableUnits: number;
    totalUnits: number;
};
