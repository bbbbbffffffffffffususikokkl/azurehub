export function unsupported(feature: string): never {
  throw new Error(
    `Nubase compatibility layer does not support ${feature} yet. Use the supported src/integrations/nubase helpers or add a verified Nubase wrapper first.`,
  )
}
