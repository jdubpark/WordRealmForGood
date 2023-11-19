import { extendTheme } from "@chakra-ui/react";

// 2. Extend the theme to include custom colors, fonts, etc
const colors = {
  supergov: {
    900: "#1a365d",
    800: "#153e75",
    700: "#2a69ac",
  },
};

export const chakraTheme = extendTheme({ colors });
