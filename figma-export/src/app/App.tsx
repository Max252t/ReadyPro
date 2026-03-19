import { ThemeProvider } from "next-themes";
import { RouterProvider } from "react-router";
import { AuthProvider } from "./context/AuthContext";
import { DataProvider } from "./context/DataContext";
import { router } from "./routes";
import { Toaster } from "./components/ui/sonner";

export default function App() {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      storageKey="readypro-theme"
      disableTransitionOnChange
    >
      <AuthProvider>
        <DataProvider>
          <RouterProvider router={router} />
          <Toaster />
        </DataProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}