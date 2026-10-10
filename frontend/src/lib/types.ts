export type UUID = string;

export type CatalogueCategory = {
	id: UUID;
	slug: string;
	name: string;
};

export type ProductImage = {
	id: UUID;
	path: string;
	alt_text: string;
	sort_order: number;
};

export type HirePeriod = {
	start: string;
	end: string;
};

export type EquipmentProduct = {
	id: UUID;
	catalogue_code: string;
	name: string;
	description: string;
	specifications: Record<string, string>;
	daily_rate_cents: number;
	hire_terms: string | null;
	category: CatalogueCategory;
	images: ProductImage[];
	total_units: number;
	operational_units: number;
	available_units: number;
	availability_period: HirePeriod | null;
};
